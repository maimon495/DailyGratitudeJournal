import SwiftUI
import SwiftData

/// Main weekly journal view with page flipping and search
struct WeeklyJournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var allEntries: [GratitudeEntry]

    @State private var currentWeekIndex = 0
    @State private var searchText = ""
    @State private var selectedEntry: GratitudeEntry?
    @State private var showSearch = false

    private var filteredEntries: [GratitudeEntry] {
        if searchText.isEmpty {
            return allEntries
        }
        return allEntries.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    private var weeks: [Date] {
        guard !filteredEntries.isEmpty else {
            // Show current week even if no entries
            let calendar = Calendar.current
            let now = Date()
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start {
                return [weekStart]
            }
            return [now]
        }

        let calendar = Calendar.current
        var weekStarts = Set<Date>()

        // Add current week
        if let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: .now)?.start {
            weekStarts.insert(currentWeekStart)
        }

        // Add weeks from entries
        for entry in filteredEntries {
            if let weekStart = calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start {
                weekStarts.insert(weekStart)
            }
        }

        return weekStarts.sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    if weeks.isEmpty {
                        emptyStateView
                    } else {
                        // Page flipping journal
                        PageFlipView(
                            pageCount: weeks.count,
                            currentPage: $currentWeekIndex
                        ) { index in
                            WeeklyJournalPageView(
                                weekStart: weeks[index],
                                entries: entriesForWeek(weeks[index]),
                                onEntryTap: { entry in
                                    selectedEntry = entry
                                }
                            )
                        }

                        // Page indicator
                        pageIndicator
                            .padding(.bottom, 8)

                        // Search bar at bottom
                        bottomSearchBar
                    }
                }
                .journalBackground()
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(JournalTheme.warmWhite, for: .navigationBar)
            .sheet(item: $selectedEntry) { entry in
                EntryDetailView(entry: entry)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(JournalTheme.goldAccent.opacity(0.5))

            VStack(spacing: 8) {
                Text("Your Journal Awaits")
                    .font(JournalTheme.journalHeadline)
                    .foregroundStyle(JournalTheme.inkNavy)

                Text("Begin your gratitude journey by writing your first entry.")
                    .font(JournalTheme.journalCaption)
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<weeks.count, id: \.self) { index in
                Circle()
                    .fill(index == currentWeekIndex ? JournalTheme.goldAccent : JournalTheme.inkCharcoal.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.vertical, 8)
    }

    private var bottomSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))

            TextField("Search entries", text: $searchText)
                .font(JournalTheme.serifFont(size: 14))
                .foregroundStyle(JournalTheme.inkNavy)
                .autocorrectionDisabled()

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.3))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(JournalTheme.cream)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private func entriesForWeek(_ weekStart: Date) -> [GratitudeEntry] {
        let calendar = Calendar.current
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart

        return filteredEntries.filter { entry in
            entry.date >= weekStart && entry.date <= weekEnd
        }
    }
}

#Preview {
    WeeklyJournalView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}
