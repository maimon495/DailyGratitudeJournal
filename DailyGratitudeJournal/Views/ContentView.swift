import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var entries: [GratitudeEntry]

    init() {
        // Style the tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Convert SwiftUI colors to UIKit
        appearance.backgroundColor = UIColor(
            red: 0.98,
            green: 0.96,
            blue: 0.92,
            alpha: 1.0
        )

        // Selected item color (gold)
        let goldColor = UIColor(
            red: 0.76,
            green: 0.60,
            blue: 0.33,
            alpha: 1.0
        )

        // Unselected item color (charcoal with opacity)
        let unselectedColor = UIColor(
            red: 0.25,
            green: 0.25,
            blue: 0.28,
            alpha: 0.5
        )

        appearance.stackedLayoutAppearance.selected.iconColor = goldColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: goldColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: unselectedColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            HistoryView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }

            OnThisDayView()
                .tabItem {
                    Label("Memories", systemImage: "sparkles")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(JournalTheme.goldAccent)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}
