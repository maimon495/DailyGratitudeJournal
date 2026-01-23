import SwiftUI

struct SplashView: View {
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showTagline = false
    @State private var showFooter = false
    @State private var isFinished = false

    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            // Background
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

                // Logo/Icon area
                VStack(spacing: 24) {
                    // Decorative ink pen icon
                    ZStack {
                        // Outer ring
                        Circle()
                            .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 2)
                            .frame(width: 100, height: 100)

                        // Inner decorative element
                        Circle()
                            .fill(JournalTheme.goldAccent.opacity(0.1))
                            .frame(width: 80, height: 80)

                        // Pen nib icon
                        Image(systemName: "pencil.and.scribble")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(JournalTheme.goldAccent)
                    }
                    .opacity(showLogo ? 1 : 0)
                    .scaleEffect(showLogo ? 1 : 0.8)

                    // Decorative line
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(JournalTheme.goldAccent.opacity(0.4))
                            .frame(width: showLogo ? 40 : 0, height: 1)

                        Image(systemName: "leaf.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(JournalTheme.goldAccent.opacity(showLogo ? 0.6 : 0))

                        Rectangle()
                            .fill(JournalTheme.goldAccent.opacity(0.4))
                            .frame(width: showLogo ? 40 : 0, height: 1)
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
                .opacity(showTitle ? 1 : 0)
                .offset(y: showTitle ? 0 : 10)

                Spacer()
                    .frame(height: 20)

                // Tagline
                Text("One Good Thing, Every Day")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
                    .opacity(showTagline ? 1 : 0)
                    .offset(y: showTagline ? 0 : 8)

                Spacer()

                // Footer
                VStack(spacing: 4) {
                    Rectangle()
                        .fill(JournalTheme.goldAccent.opacity(0.2))
                        .frame(width: 60, height: 1)

                    Text("sgtpepper development")
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .tracking(1)
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.4))
                }
                .opacity(showFooter ? 1 : 0)
                .padding(.bottom, 40)
            }
        }
        .opacity(isFinished ? 0 : 1)
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Logo fades in first
        withAnimation(.easeOut(duration: 0.6)) {
            showLogo = true
        }

        // Title appears after logo
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            showTitle = true
        }

        // Tagline appears after title
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            showTagline = true
        }

        // Footer appears last
        withAnimation(.easeOut(duration: 0.4).delay(1.1)) {
            showFooter = true
        }

        // Fade out and transition to main app
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.4)) {
                isFinished = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isActive = false
            }
        }
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}
