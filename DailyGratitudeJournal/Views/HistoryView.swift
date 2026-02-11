import SwiftUI
import SwiftData

struct HistoryView: View {
    var body: some View {
        // Use the new weekly journal view with page flipping
        WeeklyJournalView()
    }
}

// Legacy components kept for backward compatibility (no longer used)

#Preview {
    HistoryView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}
