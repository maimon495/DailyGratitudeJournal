import Foundation
import UserNotifications
import SwiftData

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime.timeIntervalSince1970, forKey: "notificationTime")
            Task {
                await scheduleNotification()
            }
        }
    }

    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                Task {
                    await requestAuthorization()
                    await scheduleNotification()
                }
            } else {
                cancelNotifications()
            }
        }
    }

    private let notificationIdentifier = "dailyGratitudeReminder"

    private init() {
        // Load saved notification time or default to 8:00 PM
        if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? TimeInterval {
            self.notificationTime = Date(timeIntervalSince1970: savedTime)
        } else {
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            self.notificationTime = Calendar.current.date(from: components) ?? .now
        }

        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")

        Task {
            await checkAuthorizationStatus()
        }
    }

    func requestAuthorization() async {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: options)
            isAuthorized = granted
        } catch {
            print("Notification authorization error: \(error)")
            isAuthorized = false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleNotification() async {
        guard notificationsEnabled && isAuthorized else { return }

        // Cancel existing notifications first
        cancelNotifications()

        let content = UNMutableNotificationContent()
        content.title = "Time for Gratitude"
        content.body = "Take a moment to reflect on something good that happened today."
        content.sound = .default
        content.badge = 1

        // Create trigger for daily notification at the specified time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let request = UNNotificationRequest(
            identifier: notificationIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Notification scheduled for \(components.hour ?? 0):\(components.minute ?? 0)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }

    func cancelNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [notificationIdentifier]
        )
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    func checkAndScheduleConditionally(hasLoggedToday: Bool) async {
        if hasLoggedToday {
            // User has logged today, cancel today's notification
            cancelNotifications()
            // Reschedule for tomorrow
            await scheduleNotification()
        }
    }
}
