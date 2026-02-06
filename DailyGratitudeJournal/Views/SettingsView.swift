import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @EnvironmentObject private var authService: AuthService
    @Query(sort: \GratitudeEntry.date, order: .reverse) private var entries: [GratitudeEntry]

    @State private var showingNotificationAlert = false

    private var totalEntries: Int {
        entries.count
    }

    private var currentStreak: Int {
        GratitudeEntry.calculateStreak(from: entries)
    }

    private var longestStreak: Int {
        calculateLongestStreak()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Statistics Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "Your Journey")

                        VStack(spacing: 0) {
                            JournalStatRow(
                                title: "Total Entries",
                                value: "\(totalEntries)",
                                icon: "book.fill",
                                color: JournalTheme.goldAccent
                            )

                            Divider()
                                .background(JournalTheme.goldAccent.opacity(0.2))

                            JournalStatRow(
                                title: "Current Streak",
                                value: "\(currentStreak) days",
                                icon: "flame.fill",
                                color: JournalTheme.copperAccent
                            )

                            Divider()
                                .background(JournalTheme.goldAccent.opacity(0.2))

                            JournalStatRow(
                                title: "Longest Streak",
                                value: "\(longestStreak) days",
                                icon: "trophy.fill",
                                color: JournalTheme.brassAccent
                            )
                        }
                        .background(JournalTheme.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(JournalTheme.goldAccent.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    }

                    // Notifications Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "Reminders")

                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(JournalTheme.goldAccent)
                                    .frame(width: 24)

                                Text("Daily Reminder")
                                    .font(JournalTheme.serifFont(size: 16))
                                    .foregroundStyle(JournalTheme.inkNavy)

                                Spacer()

                                Toggle("", isOn: $notificationManager.notificationsEnabled)
                                    .tint(JournalTheme.goldAccent)
                            }
                            .padding()

                            if notificationManager.notificationsEnabled {
                                Divider()
                                    .background(JournalTheme.goldAccent.opacity(0.2))

                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundStyle(JournalTheme.goldAccent)
                                        .frame(width: 24)

                                    Text("Reminder Time")
                                        .font(JournalTheme.serifFont(size: 16))
                                        .foregroundStyle(JournalTheme.inkNavy)

                                    Spacer()

                                    DatePicker(
                                        "",
                                        selection: $notificationManager.notificationTime,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .tint(JournalTheme.goldAccent)
                                }
                                .padding()
                            }
                        }
                        .background(JournalTheme.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(JournalTheme.goldAccent.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                        .onChange(of: notificationManager.notificationsEnabled) { _, newValue in
                            if newValue && !notificationManager.isAuthorized {
                                showingNotificationAlert = true
                            }
                        }
                    }

                    // Ink Collection
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "Ink Collection")

                        VStack(spacing: 12) {
                            ForEach(InkColor.allCases, id: \.self) { ink in
                                HStack(spacing: 12) {
                                    InkWell(color: ink, size: 24)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(ink.displayName)
                                            .font(JournalTheme.serifFont(size: 14, weight: .medium))
                                            .foregroundStyle(JournalTheme.inkNavy)

                                        Text(ink.description)
                                            .font(.caption)
                                            .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
                                    }

                                    Spacer()

                                    Text("\(entriesWithInk(ink))")
                                        .font(JournalTheme.serifFont(size: 14))
                                        .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.6))
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(JournalTheme.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(JournalTheme.goldAccent.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    }

                    // Account Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "Account")

                        VStack(spacing: 0) {
                            if let user = authService.currentUser {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(JournalTheme.goldAccent)
                                        .frame(width: 32)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(user.displayName ?? "Journaler")
                                            .font(JournalTheme.serifFont(size: 16, weight: .medium))
                                            .foregroundStyle(JournalTheme.inkNavy)

                                        if let email = user.email {
                                            Text(email)
                                                .font(.caption)
                                                .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
                                        }
                                    }

                                    Spacer()
                                }
                                .padding()

                                Divider()
                                    .background(JournalTheme.goldAccent.opacity(0.2))
                            }

                            Button {
                                authService.signOut()
                            } label: {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundStyle(JournalTheme.copperAccent)
                                        .frame(width: 24)

                                    Text("Sign Out")
                                        .font(JournalTheme.serifFont(size: 16))
                                        .foregroundStyle(JournalTheme.copperAccent)

                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        .background(JournalTheme.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(JournalTheme.goldAccent.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    }

                    // About Section
                    VStack(alignment: .leading, spacing: 16) {
                        SectionTitle(title: "About")

                        VStack(spacing: 0) {
                            HStack {
                                Text("Version")
                                    .font(JournalTheme.serifFont(size: 16))
                                    .foregroundStyle(JournalTheme.inkNavy)

                                Spacer()

                                Text("1.0.0")
                                    .font(JournalTheme.serifFont(size: 16))
                                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
                            }
                            .padding()
                        }
                        .background(JournalTheme.cream)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(JournalTheme.goldAccent.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    }

                    Spacer(minLength: 60)
                }
                .padding(.horizontal, JournalTheme.pageMargin)
                .padding(.top, 8)
            }
            .journalBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(JournalTheme.warmWhite, for: .navigationBar)
            .alert("Notifications Disabled", isPresented: $showingNotificationAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    notificationManager.notificationsEnabled = false
                }
            } message: {
                Text("Please enable notifications in Settings to receive daily reminders.")
            }
        }
    }

    private func entriesWithInk(_ ink: InkColor) -> Int {
        entries.filter { $0.inkColor == ink }.count
    }

    private func calculateLongestStreak() -> Int {
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date < $1.date }

        guard !sortedEntries.isEmpty else { return 0 }

        var longestStreak = 1
        var currentStreak = 1
        var previousDate = sortedEntries[0].date

        for i in 1..<sortedEntries.count {
            let currentDate = sortedEntries[i].date
            let daysDifference = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0

            if daysDifference == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysDifference > 1 {
                currentStreak = 1
            }

            previousDate = currentDate
        }

        return longestStreak
    }
}

struct SectionTitle: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(JournalTheme.dateStamp)
            .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.5))
            .tracking(2)
    }
}

struct JournalStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)

            Text(title)
                .font(JournalTheme.serifFont(size: 16))
                .foregroundStyle(JournalTheme.inkNavy)

            Spacer()

            Text(value)
                .font(JournalTheme.serifFont(size: 16, weight: .medium))
                .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.7))
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
        .environmentObject(AuthService.shared)
}
