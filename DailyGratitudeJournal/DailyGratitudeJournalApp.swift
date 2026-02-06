import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct DailyGratitudeJournalApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var authService = AuthService.shared
    @State private var showSplash = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([GratitudeEntry.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if authService.isAuthenticated {
                    ContentView()
                        .environmentObject(notificationManager)
                        .environmentObject(authService)
                        .onAppear {
                            notificationManager.clearBadge()
                        }
                } else {
                    LoginView()
                        .environmentObject(authService)
                }

                if showSplash {
                    SplashView(isActive: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
