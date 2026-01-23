import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var entries: [GratitudeEntry]

    @State private var selectedEntry: GratitudeEntry?
    @State private var searchText = ""

    private var filteredEntries: [GratitudeEntry] {
        if searchText.isEmpty {
            return entries
        }
        return entries.filter { $0.content.localizedCaseInsensitiveContains(searchText) }
    }

    private var groupedEntries: [(String, [GratitudeEntry])] {
        let grouped = Dictionary(grouping: filteredEntries) { entry -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: entry.date)
        }

        return grouped.sorted { first, second in
            guard let firstDate = filteredEntries.first(where: { entry in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM yyyy"
                return dateFormatter.string(from: entry.date) == first.key
            })?.date,
                  let secondDate = filteredEntries.first(where: { entry in
                      let dateFormatter = DateFormatter()
                      dateFormatter.dateFormat = "MMMM yyyy"
                      return dateFormatter.string(from: entry.date) == second.key
                  })?.date else {
                return false
            }
            return firstDate > secondDate
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    emptyStateView
                } else {
                    scrollableListView
                }
            }
            .journalBackground()
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(JournalTheme.warmWhite, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search entries")
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

    private var scrollableListView: some View {
        ScrollView {
            LazyVStack(spacing: 24, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedEntries, id: \.0) { month, monthEntries in
                    Section {
                        VStack(spacing: 12) {
                            ForEach(monthEntries) { entry in
                                JournalEntryCard(entry: entry)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedEntry = entry
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            deleteEntry(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    } header: {
                        SectionHeader(title: month)
                    }
                }
            }
            .padding(.horizontal, JournalTheme.pageMargin)
            .padding(.bottom, 40)
        }
    }

    private func deleteEntry(_ entry: GratitudeEntry) {
        withAnimation {
            modelContext.delete(entry)
            try? modelContext.save()
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(JournalTheme.dateStamp)
                .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
                .tracking(2)

            VStack {
                Divider()
                    .background(JournalTheme.goldAccent.opacity(0.3))
            }
        }
        .padding(.vertical, 12)
        .padding(.top, 8)
        .background(JournalTheme.warmWhite.opacity(0.95))
    }
}

struct JournalEntryCard: View {
    let entry: GratitudeEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                Text(entry.elegantDate)
                    .font(JournalTheme.serifFont(size: 12))
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.55))

                Spacer()

                InkWell(color: entry.inkColor, size: 16)
            }

            // Decorative line
            Rectangle()
                .fill(JournalTheme.goldAccent.opacity(0.2))
                .frame(height: 1)

            // Entry content
            InkText(entry.content, inkColor: entry.inkColor, font: entry.font.bodyFont, lineSpacing: entry.font.lineSpacing)
                .lineLimit(4)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(JournalTheme.cream)

                // Subtle page edge effect
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.5),
                                .clear,
                                .black.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(JournalTheme.goldAccent.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}
