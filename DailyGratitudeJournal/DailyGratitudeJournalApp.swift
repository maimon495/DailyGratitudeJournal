import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct DailyGratitudeJournalApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var authService = AuthService.shared
    @StateObject private var consentManager = ConsentManager.shared
    @State private var showSplash = true
    @Environment(\.scenePhase) private var scenePhase

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

        // The Mobile Ads SDK is started by ConsentManager once UMP consent
        // allows it — starting it here would request ads before consent.
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if authService.isAuthenticated {
                    ContentView()
                        .environmentObject(notificationManager)
                        .environmentObject(authService)
                        .environmentObject(consentManager)
                        .task {
                            notificationManager.clearBadge()
                            // Google's consent form must be resolved before the
                            // ATT prompt, so the two never compete for the screen.
                            await consentManager.gatherConsentAndStartAds()
                            await ATTPermissionManager.shared.requestTrackingPermission()
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
        .onChange(of: scenePhase) { _, newPhase in
            // A launch with no network leaves consent unresolved and ads off.
            // Coming back to the foreground is the natural moment to retry.
            if newPhase == .active {
                consentManager.retryIfNeeded()
            }
        }
    }
}
