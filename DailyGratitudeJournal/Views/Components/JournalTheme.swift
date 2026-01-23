import SwiftUI

enum JournalTheme {
    // MARK: - Colors

    static let cream = Color(red: 1.0, green: 0.973, blue: 0.906)
    static let warmWhite = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let parchment = Color(red: 0.96, green: 0.94, blue: 0.88)

    static let inkNavy = Color(red: 0.15, green: 0.18, blue: 0.25)
    static let inkCharcoal = Color(red: 0.25, green: 0.25, blue: 0.28)

    static let goldAccent = Color(red: 0.76, green: 0.60, blue: 0.33)
    static let brassAccent = Color(red: 0.72, green: 0.58, blue: 0.38)
    static let copperAccent = Color(red: 0.72, green: 0.45, blue: 0.35)

    static let ruledLine = Color(red: 0.75, green: 0.72, blue: 0.68).opacity(0.3)
    static let marginLine = Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.3)

    // MARK: - Static Fonts (for UI elements that don't change)

    static func serifFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    static var dateStamp: Font {
        .system(size: 12, weight: .medium, design: .serif).smallCaps()
    }

    // MARK: - Default Fonts (for UI elements)

    static var journalTitle: Font {
        .system(size: 28, weight: .medium, design: .serif)
    }

    static var journalHeadline: Font {
        .system(size: 20, weight: .medium, design: .serif)
    }

    static var journalBody: Font {
        .system(size: 18, weight: .regular, design: .serif)
    }

    static var journalCaption: Font {
        .system(size: 14, weight: .regular, design: .serif)
    }

    // MARK: - Spacing

    static let lineSpacing: CGFloat = 8
    static let paragraphSpacing: CGFloat = 16
    static let contentMaxWidth: CGFloat = 500
    static let pageMargin: CGFloat = 24

    // MARK: - Shadows

    static let pageShadow = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let subtleShadow = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifiers

struct JournalPageStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(JournalTheme.pageMargin)
            .frame(maxWidth: JournalTheme.contentMaxWidth)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(JournalTheme.cream)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .clear,
                                    .black.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .shadow(
                color: JournalTheme.pageShadow.color,
                radius: JournalTheme.pageShadow.radius,
                x: JournalTheme.pageShadow.x,
                y: JournalTheme.pageShadow.y
            )
    }
}

struct JournalBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    JournalTheme.warmWhite

                    GeometryReader { geo in
                        Canvas { context, size in
                            for _ in 0..<100 {
                                let x = CGFloat.random(in: 0...size.width)
                                let y = CGFloat.random(in: 0...size.height)
                                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                                context.fill(
                                    Path(ellipseIn: rect),
                                    with: .color(.black.opacity(Double.random(in: 0.01...0.03)))
                                )
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            )
    }
}

struct RuledPaperBackground: View {
    var lineSpacing: CGFloat = 28

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let numberOfLines = Int(geometry.size.height / lineSpacing)
                for i in 0...numberOfLines {
                    let y = CGFloat(i) * lineSpacing + 20
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
            }
            .stroke(JournalTheme.ruledLine, lineWidth: 0.5)
        }
    }
}

extension View {
    func journalPageStyle() -> some View {
        modifier(JournalPageStyle())
    }

    func journalBackground() -> some View {
        modifier(JournalBackgroundStyle())
    }
}

// MARK: - Ink Text View

struct InkText: View {
    let text: String
    let inkColor: InkColor
    let font: Font
    let lineSpacing: CGFloat

    init(_ text: String, inkColor: InkColor, font: Font? = nil, lineSpacing: CGFloat? = nil) {
        self.text = text
        self.inkColor = inkColor
        self.font = font ?? JournalTheme.journalBody
        self.lineSpacing = lineSpacing ?? JournalTheme.lineSpacing
    }

    var body: some View {
        ZStack {
            Text(text)
                .font(font)
                .foregroundStyle(inkColor.color)
                .lineSpacing(lineSpacing)

            if inkColor.hasShimmer {
                Text(text)
                    .font(font)
                    .foregroundStyle(
                        inkColor.shimmerColor
                            .blendMode(.overlay)
                    )
                    .lineSpacing(lineSpacing)
                    .mask(
                        ShimmerMask()
                    )
            }
        }
    }
}

struct ShimmerMask: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [
                    .clear,
                    .white.opacity(0.8),
                    .white,
                    .white.opacity(0.8),
                    .clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: geometry.size.width * 2)
            .offset(x: -geometry.size.width + (phase * geometry.size.width * 2))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
                ) {
                    phase = 1
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        InkText("The quick brown fox jumps over the lazy dog", inkColor: .emeraldOfChivor)
        InkText("Stormy grey ink sample", inkColor: .stormyGrey)
        InkText("Poussiere de Lune with shimmer", inkColor: .poussiereDeLune)
    }
    .padding()
    .journalBackground()
}
