import SwiftUI

/// A view that provides iBooks-style page flipping animation for journal pages
struct PageFlipView<Content: View>: View {
    let pageCount: Int
    @Binding var currentPage: Int
    let content: (Int) -> Content

    @State private var offset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Current page
                content(currentPage)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .rotation3DEffect(
                        .degrees(Double(offset / geometry.size.width) * -15),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: offset > 0 ? .leading : .trailing,
                        perspective: 0.3
                    )
                    .offset(x: offset)
                    .shadow(
                        color: .black.opacity(abs(offset) > 0 ? 0.2 : 0),
                        radius: 10,
                        x: offset > 0 ? -5 : 5
                    )

                // Next/Previous page peek
                if offset > 50 && currentPage > 0 {
                    // Previous page peek (left)
                    content(currentPage - 1)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: -geometry.size.width + offset)
                        .opacity(0.3)
                } else if offset < -50 && currentPage < pageCount - 1 {
                    // Next page peek (right)
                    content(currentPage + 1)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: geometry.size.width + offset)
                        .opacity(0.3)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let translation = value.translation.width

                        // Limit drag based on page availability
                        if translation > 0 && currentPage == 0 {
                            // First page - resist left drag
                            offset = translation * 0.2
                        } else if translation < 0 && currentPage == pageCount - 1 {
                            // Last page - resist right drag
                            offset = translation * 0.2
                        } else {
                            offset = translation
                        }
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold = geometry.size.width * 0.25
                        let velocity = value.predictedEndTranslation.width

                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if offset > threshold || velocity > 500 {
                                // Swipe right - go to previous page
                                if currentPage > 0 {
                                    currentPage -= 1
                                }
                            } else if offset < -threshold || velocity < -500 {
                                // Swipe left - go to next page
                                if currentPage < pageCount - 1 {
                                    currentPage += 1
                                }
                            }
                            offset = 0
                        }
                    }
            )
        }
    }
}

#Preview {
    struct PreviewContainer: View {
        @State private var currentPage = 0
        let pages = ["First Page", "Second Page", "Third Page", "Fourth Page"]

        var body: some View {
            VStack {
                PageFlipView(
                    pageCount: pages.count,
                    currentPage: $currentPage
                ) { index in
                    ZStack {
                        JournalTheme.cream

                        Text(pages[index])
                            .font(.largeTitle)
                            .foregroundStyle(JournalTheme.inkNavy)
                    }
                }

                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? JournalTheme.goldAccent : JournalTheme.inkCharcoal.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding()
            }
        }
    }

    return PreviewContainer()
}
