import SwiftUI
import SwiftData

struct OnThisDayView: View {
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var entries: [GratitudeEntry]

    private var onThisDayEntries: [GratitudeEntry] {
        GratitudeEntry.onThisDayEntries(from: entries)
    }

    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: .now)
    }

    var body: some View {
        NavigationStack {
            Group {
                if onThisDayEntries.isEmpty {
                    emptyStateView
                } else {
                    memoriesListView
                }
            }
            .journalBackground()
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(JournalTheme.warmWhite, for: .navigationBar)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(JournalTheme.goldAccent.opacity(0.5))

            VStack(spacing: 12) {
                Text("No Memories Yet")
                    .font(JournalTheme.journalHeadline)
                    .foregroundStyle(JournalTheme.inkNavy)

                Text("Your reflections from previous years on")
                    .font(JournalTheme.journalCaption)
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))

                Text(todayFormatted)
                    .font(JournalTheme.serifFont(size: 18, weight: .medium))
                    .foregroundStyle(JournalTheme.goldAccent)

                Text("will appear here.")
                    .font(JournalTheme.journalCaption)
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
            }
            .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private var memoriesListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("ON THIS DAY")
                        .font(JournalTheme.dateStamp)
                        .foregroundStyle(JournalTheme.goldAccent)
                        .tracking(3)

                    Text(todayFormatted)
                        .font(JournalTheme.journalTitle)
                        .foregroundStyle(JournalTheme.inkNavy)

                    // Decorative divider
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(JournalTheme.goldAccent.opacity(0.3))
                            .frame(width: 40, height: 1)

                        Image(systemName: "sparkle")
                            .font(.system(size: 10))
                            .foregroundStyle(JournalTheme.goldAccent.opacity(0.6))

                        Rectangle()
                            .fill(JournalTheme.goldAccent.opacity(0.3))
                            .frame(width: 40, height: 1)
                    }
                }
                .padding(.top, 20)

                // Memory cards
                ForEach(onThisDayEntries) { entry in
                    MemoryCard(entry: entry)
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, JournalTheme.pageMargin)
        }
    }
}

struct MemoryCard: View {
    let entry: GratitudeEntry

    private var yearsAgo: Int {
        let currentYear = Calendar.current.component(.year, from: .now)
        return currentYear - entry.year
    }

    private var yearsAgoText: String {
        if yearsAgo == 1 {
            return "One year ago"
        }
        return "\(yearsAgo) years ago"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Year badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 12))
                    Text(yearsAgoText)
                        .font(JournalTheme.serifFont(size: 13, weight: .medium))
                }
                .foregroundStyle(JournalTheme.goldAccent)

                Spacer()

                Text(String(entry.year))
                    .font(JournalTheme.dateStamp)
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.4))
                    .tracking(1)
            }

            // Decorative line
            Rectangle()
                .fill(JournalTheme.goldAccent.opacity(0.2))
                .frame(height: 1)

            // Entry content with ink color
            ZStack(alignment: .topLeading) {
                InkText(entry.content, inkColor: entry.inkColor, font: entry.font.bodyFont, lineSpacing: entry.font.lineSpacing)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Ink and font indicator
            HStack(spacing: 6) {
                InkWell(color: entry.inkColor, size: 12)
                Text(entry.inkColor.displayName)
                    .font(.caption)
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.4))

                Text("·")
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.3))

                Text(entry.font.displayName)
                    .font(.caption)
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.4))
            }
        }
        .padding(JournalTheme.pageMargin)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(JournalTheme.cream)

                // Aged paper effect
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.4),
                                JournalTheme.parchment.opacity(0.3),
                                .black.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(JournalTheme.goldAccent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

#Preview {
    OnThisDayView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}
