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

    /// Identifies the content currently on screen. Only the visible week is
    /// hashed, so this stays cheap no matter how long the journal gets.
    private var visiblePageVersion: Int {
        var hasher = Hasher()
        hasher.combine(weeks.count)
        let index = min(max(currentWeekIndex, 0), max(weeks.count - 1, 0))
        if weeks.indices.contains(index) {
            for entry in entriesForWeek(weeks[index]) {
                hasher.combine(entry.id)
                hasher.combine(entry.content)
                hasher.combine(entry.inkColorRaw)
                hasher.combine(entry.fontRaw)
            }
        }
        return hasher.finalize()
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
                        PageCurlView(
                            pageCount: weeks.count,
                            currentPage: $currentWeekIndex,
                            contentVersion: visiblePageVersion
                        ) { index in
                            // Searching shrinks the week list. Without clamping,
                            // a stale page index reads past the end and crashes.
                            let week = weeks[min(max(index, 0), weeks.count - 1)]
                            return WeeklyJournalPageView(
                                weekStart: week,
                                entries: entriesForWeek(week),
                                onEntryTap: { entry in
                                    selectedEntry = entry
                                }
                            )
                        }
                        .onChange(of: weeks.count) { _, newCount in
                            if currentWeekIndex >= newCount {
                                currentWeekIndex = max(newCount - 1, 0)
                            }
                        }

                        // Page indicator
                        pageIndicator
                            .padding(.bottom, 8)

                        // Search bar at bottom
                        bottomSearchBar

                        BannerAdView()
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

    @ViewBuilder
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

    @ViewBuilder
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

    @ViewBuilder
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

struct WeeklyJournalView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyJournalView()
            .modelContainer(for: GratitudeEntry.self, inMemory: true)
    }
}
