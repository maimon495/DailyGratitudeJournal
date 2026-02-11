import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var entry: GratitudeEntry

    @State private var isEditing = false
    @State private var editedContent: String = ""
    @State private var editedInkColor: InkColor = .stormyGrey
    @State private var editedFont: JournalFont = .classicSerif
    @State private var showingDeleteConfirmation = false

    // Read-only mode: saved entries cannot be edited (like writing in pen)
    private var isReadOnly: Bool {
        // Entry is read-only if it has been saved (exists in the database)
        // In bullet journaling, you write in pen - no editing allowed!
        return true
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Date header with elegant styling
                    dateHeaderView

                    // Content area
                    if isEditing {
                        editingView
                    } else {
                        contentView
                    }

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, JournalTheme.pageMargin)
                .frame(maxWidth: JournalTheme.contentMaxWidth)
                .frame(maxWidth: .infinity)
            }
            .journalBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(JournalTheme.warmWhite, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(JournalTheme.serifFont(size: 16))
                            .foregroundStyle(JournalTheme.goldAccent)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        if !isReadOnly {
                            Button {
                                editedContent = entry.content
                                editedInkColor = entry.inkColor
                                editedFont = entry.font
                                isEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }

                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                            .foregroundStyle(JournalTheme.goldAccent)
                    }
                }
            }
            .confirmationDialog(
                "Delete Entry",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteEntry()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This entry will be permanently removed from your journal.")
            }
        }
    }

    private var dateHeaderView: some View {
        VStack(spacing: 8) {
            // Decorative element
            HStack(spacing: 16) {
                Rectangle()
                    .fill(JournalTheme.goldAccent.opacity(0.3))
                    .frame(height: 1)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(JournalTheme.goldAccent.opacity(0.6))

                Rectangle()
                    .fill(JournalTheme.goldAccent.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.top, 20)

            Text(entry.elegantDate)
                .font(JournalTheme.serifFont(size: 14))
                .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
        }
    }

    private var contentView: some View {
        VStack(spacing: 24) {
            // Journal page styling
            VStack(spacing: 20) {
                // Ruled lines behind text
                ZStack(alignment: .topLeading) {
                    RuledPaperBackground(lineSpacing: entry.font.lineSpacing + 20)
                        .frame(minHeight: 200)

                    InkText(entry.content, inkColor: entry.inkColor, font: entry.font.bodyFont, lineSpacing: entry.font.lineSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }
            }
            .padding(JournalTheme.pageMargin)
            .journalPageStyle()

            // Read-only indicator (like ink in a journal)
            if isReadOnly {
                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.4))

                    Text("Written in permanent ink")
                        .font(JournalTheme.serifFont(size: 12))
                        .italic()
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.4))
                }
                .padding(.top, -8)
            }

            // Ink and font indicator
            HStack(spacing: 8) {
                InkWell(color: entry.inkColor, size: 18)

                Text("Written in \(entry.inkColor.displayName)")
                    .font(JournalTheme.serifFont(size: 13))
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))

                Text("·")
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.3))

                Text(entry.font.displayName)
                    .font(JournalTheme.serifFont(size: 13))
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
            }
        }
    }

    private var editingView: some View {
        VStack(spacing: 20) {
            // Text editor with ruled paper
            ZStack(alignment: .topLeading) {
                RuledPaperBackground(lineSpacing: editedFont.lineSpacing + 20)

                TextEditor(text: $editedContent)
                    .font(editedFont.bodyFont)
                    .foregroundStyle(editedInkColor.color)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .lineSpacing(editedFont.lineSpacing)
                    .frame(minHeight: 200)

                if editedContent.isEmpty {
                    Text("Write your thoughts...")
                        .font(editedFont.bodyFont)
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.3))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                        .allowsHitTesting(false)
                }
            }
            .padding(JournalTheme.pageMargin)
            .background(JournalTheme.cream)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

            // Ink color picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your ink")
                    .font(JournalTheme.serifFont(size: 13))
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))

                CompactInkPicker(selectedColor: $editedInkColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Font picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose your font")
                    .font(JournalTheme.serifFont(size: 13))
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))

                CompactFontPicker(selectedFont: $editedFont)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Action buttons
            HStack(spacing: 16) {
                Button {
                    isEditing = false
                    editedContent = ""
                } label: {
                    Text("Cancel")
                        .font(JournalTheme.serifFont(size: 15))
                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(JournalTheme.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(JournalTheme.goldAccent.opacity(0.3), lineWidth: 1)
                        )
                }

                Button {
                    saveChanges()
                } label: {
                    Text("Save")
                        .font(JournalTheme.serifFont(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? JournalTheme.inkCharcoal.opacity(0.3)
                                : JournalTheme.goldAccent
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(editedContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func saveChanges() {
        let trimmedContent = editedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return }

        entry.content = trimmedContent
        entry.inkColor = editedInkColor
        entry.font = editedFont
        try? modelContext.save()

        isEditing = false
        editedContent = ""
    }

    private func deleteEntry() {
        modelContext.delete(entry)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    EntryDetailView(entry: GratitudeEntry(content: "Had a wonderful day at the park with family. The weather was perfect and we had a great picnic under the old oak tree.", inkColor: .emeraldOfChivor))
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}
