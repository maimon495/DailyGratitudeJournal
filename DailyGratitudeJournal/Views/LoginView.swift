import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var appleSignInHelper = AppleSignInHelper()

    var body: some View {
        ZStack {
            // Cream background
            JournalTheme.cream
                .ignoresSafeArea()

            // Subtle paper texture
            GeometryReader { geo in
                Canvas { context, size in
                    for _ in 0..<80 {
                        let x = CGFloat.random(in: 0...size.width)
                        let y = CGFloat.random(in: 0...size.height)
                        let rect = CGRect(x: x, y: y, width: 1, height: 1)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(.black.opacity(Double.random(in: 0.01...0.02)))
                        )
                    }
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo/Icon area (matching splash)
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 2)
                            .frame(width: 100, height: 100)

                        Circle()
                            .fill(JournalTheme.goldAccent.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(JournalTheme.goldAccent)
                    }

                    // Decorative line
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(JournalTheme.goldAccent.opacity(0.4))
                            .frame(width: 40, height: 1)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(JournalTheme.goldAccent.opacity(0.6))

                        Rectangle()
                            .fill(JournalTheme.goldAccent.opacity(0.4))
                            .frame(width: 40, height: 1)
                    }
                }

                Spacer()
                    .frame(height: 40)

                // App Title
                VStack(spacing: 8) {
                    Text("Daily Gratitude")
                        .font(.system(size: 32, weight: .light, design: .serif))
                        .foregroundStyle(JournalTheme.inkNavy)

                    Text("Journal")
                        .font(.system(size: 36, weight: .medium, design: .serif))
                        .foregroundStyle(JournalTheme.inkNavy)
                }

                Spacer()
                    .frame(height: 20)

                Text("Begin your journey of gratitude")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))

                Spacer()
                    .frame(height: 60)

                // Sign-in buttons
                VStack(spacing: 16) {
                    // Sign in with Apple
                    Button {
                        Task {
                            await signInWithApple()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20, weight: .medium))
                            Text("Continue with Apple")
                                .font(JournalTheme.serifFont(size: 17, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(JournalTheme.inkNavy)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Sign in with Google
                    Button {
                        Task {
                            await authService.signInWithGoogle()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            // Google "G" icon
                            Text("G")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            Text("Continue with Google")
                                .font(JournalTheme.serifFont(size: 17, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(JournalTheme.goldAccent)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: JournalTheme.goldAccent.opacity(0.3), radius: 8, y: 4)
                    }
                }
                .padding(.horizontal, 40)
                .disabled(authService.isLoading)
                .opacity(authService.isLoading ? 0.6 : 1.0)

                if authService.isLoading {
                    ProgressView()
                        .tint(JournalTheme.goldAccent)
                        .padding(.top, 20)
                }

                if let error = authService.error {
                    Text(error.localizedDescription)
                        .font(JournalTheme.journalCaption)
                        .foregroundStyle(JournalTheme.copperAccent)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Footer (matching splash)
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(JournalTheme.goldAccent.opacity(0.2))
                        .frame(width: 60, height: 1)

                    Text("sgtpepper development")
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .tracking(1)
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.4))
                }
                .padding(.bottom, 40)
            }
        }
    }

    private func signInWithApple() async {
        do {
            let credential = try await appleSignInHelper.signIn()
            guard let nonce = appleSignInHelper.nonce else { return }
            await authService.signInWithApple(credential: credential, nonce: nonce)
        } catch {
            // User cancelled - don't show error
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                authService.error = .signInFailed(error.localizedDescription)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService.shared)
}
