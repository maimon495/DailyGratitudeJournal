import Foundation
import SwiftData
import SwiftUI

@Model
final class GratitudeEntry {
    var id: UUID
    var date: Date
    var content: String
    var createdAt: Date
    var inkColorRaw: String
    var fontRaw: String

    init(date: Date = .now, content: String, inkColor: InkColor = .stormyGrey, font: JournalFont = .classicSerif) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.content = content
        self.createdAt = .now
        self.inkColorRaw = inkColor.rawValue
        self.fontRaw = font.rawValue
    }

    var inkColor: InkColor {
        get { InkColor(rawValue: inkColorRaw) ?? .stormyGrey }
        set { inkColorRaw = newValue.rawValue }
    }

    var font: JournalFont {
        get { JournalFont(rawValue: fontRaw) ?? .classicSerif }
        set { fontRaw = newValue.rawValue }
    }

    var formattedDate: String {
        date.formatted(date: .long, time: .omitted)
    }

    var dayAndMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }

    var year: Int {
        Calendar.current.component(.year, from: date)
    }

    var elegantDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

extension GratitudeEntry {
    static func entriesForToday(in entries: [GratitudeEntry]) -> GratitudeEntry? {
        let today = Calendar.current.startOfDay(for: .now)
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    static func onThisDayEntries(from entries: [GratitudeEntry]) -> [GratitudeEntry] {
        let calendar = Calendar.current
        let today = Date.now
        let currentMonth = calendar.component(.month, from: today)
        let currentDay = calendar.component(.day, from: today)
        let currentYear = calendar.component(.year, from: today)

        return entries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date)
            let entryDay = calendar.component(.day, from: entry.date)
            let entryYear = calendar.component(.year, from: entry.date)

            return entryMonth == currentMonth && entryDay == currentDay && entryYear != currentYear
        }.sorted { $0.date > $1.date }
    }

    static func calculateStreak(from entries: [GratitudeEntry]) -> Int {
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date > $1.date }

        guard !sortedEntries.isEmpty else { return 0 }

        var streak = 0
        var currentDate = calendar.startOfDay(for: .now)

        let todayEntry = sortedEntries.first { calendar.isDate($0.date, inSameDayAs: currentDate) }
        if todayEntry == nil {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)

            if calendar.isDate(entryDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if entryDate < currentDate {
                break
            }
        }

        return streak
    }
}
