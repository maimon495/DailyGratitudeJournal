import SwiftUI

struct InkColorPicker: View {
    @Binding var selectedColor: InkColor
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header button
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    InkWell(color: selectedColor, size: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedColor.displayName)
                            .font(JournalTheme.serifFont(size: 15, weight: .medium))
                            .foregroundStyle(JournalTheme.inkNavy)

                        Text(selectedColor.description)
                            .font(.caption)
                            .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(JournalTheme.goldAccent)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(JournalTheme.cream)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Expanded color grid
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(InkColor.allCases, id: \.self) { ink in
                        InkColorRow(
                            ink: ink,
                            isSelected: selectedColor == ink
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedColor = ink
                                isExpanded = false
                            }
                        }
                    }
                }
                .padding(12)
                .background(JournalTheme.cream)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 1)
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
            }
        }
    }
}

struct InkColorRow: View {
    let ink: InkColor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                InkWell(color: ink, size: 24)

                VStack(alignment: .leading, spacing: 1) {
                    Text(ink.displayName)
                        .font(JournalTheme.serifFont(size: 14, weight: .medium))
                        .foregroundStyle(JournalTheme.inkNavy)

                    Text(ink.description)
                        .font(.caption2)
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(JournalTheme.goldAccent)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? JournalTheme.goldAccent.opacity(0.1) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct InkWell: View {
    let color: InkColor
    let size: CGFloat

    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        ZStack {
            // Base ink color
            Circle()
                .fill(color.color)
                .frame(width: size, height: size)

            // Glass/wet ink effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.4),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)

            // Shimmer for special inks
            if color.hasShimmer {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [
                                color.shimmerColor.opacity(0.8),
                                .clear,
                                color.shimmerColor.opacity(0.6),
                                .clear,
                                color.shimmerColor.opacity(0.8)
                            ],
                            center: .center,
                            angle: .degrees(shimmerPhase * 360)
                        )
                    )
                    .frame(width: size, height: size)
                    .blendMode(.overlay)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 4)
                            .repeatForever(autoreverses: false)
                        ) {
                            shimmerPhase = 1
                        }
                    }
            }

            // Border
            Circle()
                .stroke(JournalTheme.goldAccent.opacity(0.4), lineWidth: 1)
                .frame(width: size, height: size)
        }
    }
}

struct CompactInkPicker: View {
    @Binding var selectedColor: InkColor

    var body: some View {
        HStack(spacing: 12) {
            ForEach(InkColor.allCases, id: \.self) { ink in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedColor = ink
                    }
                } label: {
                    InkWell(color: ink, size: selectedColor == ink ? 36 : 28)
                        .overlay(
                            Circle()
                                .stroke(JournalTheme.goldAccent, lineWidth: selectedColor == ink ? 2 : 0)
                                .frame(width: selectedColor == ink ? 42 : 34)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct CompactFontPicker: View {
    @Binding var selectedFont: JournalFont
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Collapsed header showing current selection
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "textformat")
                        .font(.system(size: 14))
                        .foregroundStyle(JournalTheme.goldAccent)

                    Text(selectedFont.displayName)
                        .font(selectedFont.font(size: 15, weight: .medium))
                        .foregroundStyle(JournalTheme.inkNavy)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(JournalTheme.goldAccent)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(JournalTheme.cream)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Expanded font options
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(JournalFont.allCases) { font in
                        HStack {
                            Text(font.displayName)
                                .font(font.font(size: 15, weight: .medium))
                                .foregroundStyle(selectedFont == font ? JournalTheme.goldAccent : JournalTheme.inkNavy)

                            Spacer()

                            if selectedFont == font {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(JournalTheme.goldAccent)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(selectedFont == font ? JournalTheme.goldAccent.opacity(0.1) : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedFont = font
                                isExpanded = false
                            }
                        }
                    }
                }
                .padding(8)
                .background(JournalTheme.cream)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 1)
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        InkColorPicker(selectedColor: .constant(.emeraldOfChivor))

        CompactInkPicker(selectedColor: .constant(.poussiereDeLune))

        CompactFontPicker(selectedFont: .constant(.classicSerif))
    }
    .padding()
    .journalBackground()
}
