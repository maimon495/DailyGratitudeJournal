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
