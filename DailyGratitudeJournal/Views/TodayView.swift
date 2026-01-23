import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var notificationManager: NotificationManager
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var entries: [GratitudeEntry]

    @State private var entryText = ""
    @State private var selectedInkColor: InkColor = .stormyGrey
    @State private var selectedFont: JournalFont = .classicSerif
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool

    private var todaysEntry: GratitudeEntry? {
        GratitudeEntry.entriesForToday(in: entries)
    }

    private var streak: Int {
        GratitudeEntry.calculateStreak(from: entries)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private var elegantDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: .now)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection

                    if streak > 0 {
                        streakBadge
                    }

                    if let entry = todaysEntry, !isEditing {
                        completedEntryView(entry)
                    } else {
                        entryInputView
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, JournalTheme.pageMargin)
                .frame(maxWidth: .infinity)
            }
            .journalBackground()
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(JournalTheme.warmWhite, for: .navigationBar)
            .toolbar {
                if todaysEntry != nil && !isEditing {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            entryText = todaysEntry?.content ?? ""
                            selectedInkColor = todaysEntry?.inkColor ?? .stormyGrey
                            selectedFont = todaysEntry?.font ?? .classicSerif
                            isEditing = true
                            isTextFieldFocused = true
                        } label: {
                            Text("Edit")
                                .font(JournalTheme.serifFont(size: 16))
                                .foregroundStyle(JournalTheme.goldAccent)
                        }
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(greeting)
                .font(JournalTheme.journalTitle)
                .foregroundStyle(JournalTheme.inkNavy)

            Text(elegantDate)
                .font(JournalTheme.serifFont(size: 13))
                .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundStyle(JournalTheme.copperAccent)
            Text("\(streak) day streak")
                .font(JournalTheme.serifFont(size: 14, weight: .medium))
                .foregroundStyle(JournalTheme.inkCharcoal)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(JournalTheme.cream)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
        .overlay(
            Capsule()
                .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 1)
        )
    }

    private func completedEntryView(_ entry: GratitudeEntry) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 28))
                .foregroundStyle(JournalTheme.goldAccent.opacity(0.6))

            Text("Today's Reflection")
                .font(JournalTheme.dateStamp)
                .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
                .tracking(2)

            VStack(spacing: 16) {
                InkText(entry.content, inkColor: entry.inkColor, font: entry.font.bodyFont, lineSpacing: entry.font.lineSpacing)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                HStack(spacing: 6) {
                    InkWell(color: entry.inkColor, size: 12)
                    Text(entry.inkColor.displayName)
                        .font(.caption)
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))

                    Text("·")
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.3))

                    Text(entry.font.displayName)
                        .font(.caption)
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
                }
            }
            .padding(JournalTheme.pageMargin)
            .journalPageStyle()
        }
        .padding(.top, 12)
    }

    private var entryInputView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "pencil.line")
                    .font(.system(size: 32))
                    .foregroundStyle(JournalTheme.goldAccent)

                Text("What brought you joy today?")
                    .font(JournalTheme.journalHeadline)
                    .foregroundStyle(JournalTheme.inkNavy)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                ZStack(alignment: .topLeading) {
                    RuledPaperBackground(lineSpacing: selectedFont.lineSpacing + 20)

                    TextEditor(text: $entryText)
                        .focused($isTextFieldFocused)
                        .font(selectedFont.bodyFont)
                        .foregroundStyle(selectedInkColor.color)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .lineSpacing(selectedFont.lineSpacing)
                        .frame(minHeight: 180)

                    if entryText.isEmpty {
                        Text("Begin writing...")
                            .font(selectedFont.bodyFont)
                            .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.3))
                            .padding(.top, 8)
                            .padding(.leading, 5)
                            .allowsHitTesting(false)
                    }
                }
                .padding()
                .background(JournalTheme.cream)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isTextFieldFocused ? JournalTheme.goldAccent : JournalTheme.goldAccent.opacity(0.3),
                            lineWidth: isTextFieldFocused ? 2 : 1
                        )
                )
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your ink")
                        .font(JournalTheme.serifFont(size: 13))
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))

                    CompactInkPicker(selectedColor: $selectedInkColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your font")
                        .font(JournalTheme.serifFont(size: 13))
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))

                    CompactFontPicker(selectedFont: $selectedFont)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: saveEntry) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.pencil")
                        Text(isEditing ? "Update Entry" : "Save Entry")
                    }
                    .font(JournalTheme.serifFont(size: 16, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? JournalTheme.inkCharcoal.opacity(0.3)
                            : JournalTheme.goldAccent
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(
                        color: entryText.isEmpty ? .clear : JournalTheme.goldAccent.opacity(0.3),
                        radius: 8,
                        y: 4
                    )
                }
                .disabled(entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if isEditing {
                    Button("Cancel") {
                        isEditing = false
                        entryText = ""
                        isTextFieldFocused = false
                    }
                    .font(JournalTheme.serifFont(size: 15))
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
                }
            }
        }
        .padding(.top, 12)
    }

    private func saveEntry() {
        let trimmedText = entryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        if let existingEntry = todaysEntry {
            existingEntry.content = trimmedText
            existingEntry.inkColor = selectedInkColor
            existingEntry.font = selectedFont
        } else {
            let newEntry = GratitudeEntry(content: trimmedText, inkColor: selectedInkColor, font: selectedFont)
            modelContext.insert(newEntry)
        }

        do {
            try modelContext.save()
            entryText = ""
            isEditing = false
            isTextFieldFocused = false

            Task {
                await notificationManager.checkAndScheduleConditionally(hasLoggedToday: true)
            }
        } catch {
            print("Error saving entry: \(error)")
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}
