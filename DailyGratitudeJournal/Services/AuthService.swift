import Foundation
import AuthenticationServices
import UIKit

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

enum AuthError: LocalizedError {
    case signInFailed(String)
    case signOutFailed(String)
    case noRootViewController
    case invalidCredential
    case firebaseNotConfigured
    case deleteAccountFailed(String)
    case reauthenticationRequired

    var errorDescription: String? {
        switch self {
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .noRootViewController:
            return "Unable to present sign-in"
        case .invalidCredential:
            return "Invalid credentials"
        case .firebaseNotConfigured:
            return "Firebase is not configured. Please add Firebase packages."
        case .deleteAccountFailed(let message):
            return "Couldn't delete your account: \(message)"
        case .reauthenticationRequired:
            return "For your security, please sign out and sign back in, then delete your account again."
        }
    }
}

// User info wrapper that works with or without Firebase
struct AuthUser {
    let uid: String
    let email: String?
    let displayName: String?
}

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var isAuthenticated = false
    @Published var currentUser: AuthUser?
    @Published var isLoading = false
    @Published var error: AuthError?

    #if canImport(FirebaseAuth)
    private var authStateListener: AuthStateDidChangeListenerHandle?
    #endif

    /// Held while an Apple re-authentication request is in flight. Letting the
    /// helper deallocate mid-request is what produced "Sign in with Apple
    /// error 1000" previously.
    private var appleReauthHelper: AppleSignInHelper?

    private init() {
        setupAuthStateListener()
    }

    private func setupAuthStateListener() {
        #if canImport(FirebaseAuth)
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    self?.currentUser = AuthUser(
                        uid: user.uid,
                        email: user.email,
                        displayName: user.displayName
                    )
                    self?.isAuthenticated = true
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
        #endif
    }

    // MARK: - Sign in with Apple

    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async {
        #if canImport(FirebaseAuth)
        isLoading = true
        error = nil

        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            error = .invalidCredential
            isLoading = false
            return
        }

        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )

        do {
            _ = try await Auth.auth().signIn(with: firebaseCredential)
        } catch {
            self.error = .signInFailed(error.localizedDescription)
        }

        isLoading = false
        #else
        error = .firebaseNotConfigured
        #endif
    }

    // MARK: - Sign in with Google

    func signInWithGoogle() async {
        #if canImport(FirebaseAuth) && canImport(GoogleSignIn) && canImport(FirebaseCore)
        isLoading = true
        error = nil

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            error = .signInFailed("Missing Firebase client ID")
            isLoading = false
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            error = .noRootViewController
            isLoading = false
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            guard let idToken = result.user.idToken?.tokenString else {
                error = .invalidCredential
                isLoading = false
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )

            _ = try await Auth.auth().signIn(with: credential)
        } catch {
            // Don't show error for user cancellation
            if (error as NSError).code != GIDSignInError.canceled.rawValue {
                self.error = .signInFailed(error.localizedDescription)
            }
        }

        isLoading = false
        #else
        error = .firebaseNotConfigured
        #endif
    }

    // MARK: - Delete Account

    /// Permanently deletes the signed-in account.
    ///
    /// App Store Review Guideline 5.1.1(v) requires any app that supports
    /// account creation to also offer in-app account deletion.
    ///
    /// Firebase only deletes an account for a recently authenticated user, and
    /// a session more than a few minutes old does not qualify. So the user is
    /// re-authenticated with their original provider first — otherwise deletion
    /// dead-ends for anyone who did not just sign in, which a reviewer would
    /// hit and reject.
    ///
    /// Returns true when the account was deleted.
    @discardableResult
    func deleteAccount() async -> Bool {
        #if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            error = .deleteAccountFailed("No signed-in user")
            return false
        }

        isLoading = true
        error = nil

        do {
            // Prove identity again, and collect Apple's authorization code if
            // that is the provider — Apple requires the token be revoked when
            // an account is deleted, not merely unlinked.
            let appleAuthorizationCode = try await reauthenticate(user)

            if let appleAuthorizationCode {
                // Best effort: revocation failing should not block the user
                // from deleting their account.
                do {
                    try await Auth.auth().revokeToken(withAuthorizationCode: appleAuthorizationCode)
                } catch {
                    print("AuthService: Apple token revocation failed — \(error.localizedDescription)")
                }
            }

            try await user.delete()
            #if canImport(GoogleSignIn)
            GIDSignIn.sharedInstance.signOut()
            #endif
            isLoading = false
            return true
        } catch is CancellationError {
            // The user backed out of the re-authentication prompt.
            isLoading = false
            return false
        } catch {
            let nsError = error as NSError
            if nsError.code == ASAuthorizationError.canceled.rawValue,
               nsError.domain == ASAuthorizationError.errorDomain {
                isLoading = false
                return false
            }
            if nsError.code == AuthErrorCode.requiresRecentLogin.rawValue {
                self.error = .reauthenticationRequired
            } else {
                self.error = .deleteAccountFailed(error.localizedDescription)
            }
            isLoading = false
            return false
        }
        #else
        error = .firebaseNotConfigured
        return false
        #endif
    }

    #if canImport(FirebaseAuth)
    /// Re-authenticates the user with whichever provider they originally used.
    /// Returns Apple's authorization code when the provider was Apple, so the
    /// caller can revoke the token.
    private func reauthenticate(_ user: User) async throws -> String? {
        let providerIDs = user.providerData.map(\.providerID)

        if providerIDs.contains("apple.com") {
            let helper = AppleSignInHelper()
            appleReauthHelper = helper  // held for the life of the request
            defer { appleReauthHelper = nil }

            let credential = try await helper.signIn()
            guard let identityToken = credential.identityToken,
                  let idTokenString = String(data: identityToken, encoding: .utf8),
                  let nonce = helper.nonce else {
                throw AuthError.invalidCredential
            }

            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )
            try await user.reauthenticate(with: firebaseCredential)

            return credential.authorizationCode
                .flatMap { String(data: $0, encoding: .utf8) }
        }

        #if canImport(GoogleSignIn) && canImport(FirebaseCore)
        if providerIDs.contains("google.com") {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.keyWindow?.rootViewController else {
                throw AuthError.noRootViewController
            }

            if let clientID = FirebaseApp.app()?.options.clientID {
                GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            }

            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.invalidCredential
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            try await user.reauthenticate(with: credential)
            return nil
        }
        #endif

        // Unknown provider — let the delete attempt surface the real error.
        return nil
    }
    #endif

    // MARK: - Sign Out

    func signOut() {
        #if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()
            #if canImport(GoogleSignIn)
            GIDSignIn.sharedInstance.signOut()
            #endif
        } catch {
            self.error = .signOutFailed(error.localizedDescription)
        }
        #else
        isAuthenticated = false
        currentUser = nil
        #endif
    }
}
