import SwiftUI

/// Represents a single week's journal page with a notebook spread layout
struct WeeklyJournalPageView: View {
    let weekStart: Date
    let entries: [GratitudeEntry]
    let onEntryTap: (GratitudeEntry) -> Void

    private var weekEnd: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
    }

    private var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startString = formatter.string(from: weekStart)
        let endDate = weekEnd

        // Check if same month
        let startMonth = Calendar.current.component(.month, from: weekStart)
        let endMonth = Calendar.current.component(.month, from: endDate)

        if startMonth == endMonth {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "d, yyyy"
            return "\(startString)-\(dayFormatter.string(from: endDate))"
        } else {
            formatter.dateFormat = "MMM d, yyyy"
            return "\(startString) - \(formatter.string(from: endDate))"
        }
    }

    private var daysOfWeek: [Date] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left page (blank for aesthetic)
                leftPage
                    .frame(width: geometry.size.width / 2)

                // Binding/spine shadow
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.2),
                                Color.black.opacity(0.05),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 8)

                // Right page (journal entries)
                rightPage
                    .frame(width: geometry.size.width / 2 - 4)
            }
        }
        .background(JournalTheme.warmWhite)
    }

    private var leftPage: some View {
        ZStack {
            // Cream background
            JournalTheme.cream

            // Subtle texture
            Canvas { context, size in
                for _ in 0..<50 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 1, height: 1)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(.black.opacity(Double.random(in: 0.01...0.02)))
                    )
                }
            }

            // Optional decorative element
            VStack {
                Spacer()
                Image(systemName: "book.closed")
                    .font(.system(size: 40))
                    .foregroundStyle(JournalTheme.goldAccent.opacity(0.1))
                Spacer()
            }
        }
    }

    private var rightPage: some View {
        ZStack(alignment: .topLeading) {
            // Page background with ruled lines
            JournalTheme.cream

            RuledPaperBackground(lineSpacing: 32)

            // Margin line (left red line)
            Rectangle()
                .fill(JournalTheme.marginLine)
                .frame(width: 1)
                .padding(.leading, 40)

            // Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Week header
                    Text(weekDateRange)
                        .font(JournalTheme.serifFont(size: 16, weight: .medium))
                        .foregroundStyle(JournalTheme.inkNavy)
                        .padding(.leading, 50)
                        .padding(.top, 30)
                        .padding(.bottom, 20)

                    // Days of the week
                    ForEach(daysOfWeek, id: \.self) { day in
                        DayEntryRow(
                            date: day,
                            entry: entryForDate(day),
                            onTap: onEntryTap
                        )
                    }

                    Spacer(minLength: 40)
                }
            }
            .padding(.trailing, 20)
        }
    }

    private func entryForDate(_ date: Date) -> GratitudeEntry? {
        entries.first { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
    }
}

/// A single day's entry row in the bullet journal style
struct DayEntryRow: View {
    let date: Date
    let entry: GratitudeEntry?
    let onTap: (GratitudeEntry) -> Void

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    private var isPast: Bool {
        date < Calendar.current.startOfDay(for: .now)
    }

    private var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Date header
            HStack(spacing: 8) {
                // Bullet point
                Circle()
                    .fill(entry != nil ? JournalTheme.goldAccent : JournalTheme.inkCharcoal.opacity(0.2))
                    .frame(width: 6, height: 6)

                Text(dayLabel)
                    .font(JournalTheme.serifFont(size: 13, weight: .medium))
                    .foregroundStyle(
                        isToday ? JournalTheme.goldAccent : JournalTheme.inkCharcoal.opacity(0.6)
                    )

                if let entry = entry {
                    Spacer()
                    InkWell(color: entry.inkColor, size: 12)
                }
            }
            .padding(.leading, 50)
            .padding(.trailing, 10)

            // Entry content (if exists)
            if let entry = entry {
                InkText(
                    entry.content,
                    inkColor: entry.inkColor,
                    font: entry.font.bodyFont,
                    lineSpacing: entry.font.lineSpacing
                )
                .font(.system(size: 15, design: .serif))
                .lineLimit(3)
                .padding(.leading, 64)
                .padding(.trailing, 10)
                .padding(.bottom, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap(entry)
                }
                .opacity(isPast ? 0.85 : 1.0)
            } else {
                // Empty entry placeholder
                Text("No entry")
                    .font(JournalTheme.serifFont(size: 14))
                    .italic()
                    .foregroundStyle(JournalTheme.inkCharcoal.opacity(0.25))
                    .padding(.leading, 64)
                    .padding(.bottom, 8)
            }

            // Divider
            Rectangle()
                .fill(JournalTheme.goldAccent.opacity(0.1))
                .frame(height: 0.5)
                .padding(.leading, 50)
        }
        .padding(.vertical, 6)
    }
}

/// Ink well color indicator
struct InkWell: View {
    let color: InkColor
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color.color)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
            )
    }
}

#Preview {
    let calendar = Calendar.current
    let today = Date()
    let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today

    // Sample entries
    let sampleEntries = [
        GratitudeEntry(
            date: calendar.date(byAdding: .day, value: 0, to: weekStart) ?? today,
            content: "Beautiful morning walk with crisp air and golden sunlight",
            inkColor: .emeraldOfChivor,
            font: .classicSerif
        ),
        GratitudeEntry(
            date: calendar.date(byAdding: .day, value: 1, to: weekStart) ?? today,
            content: "Yummy meal prep lunch.",
            inkColor: .midnightBlue,
            font: .modernSans
        ),
        GratitudeEntry(
            date: calendar.date(byAdding: .day, value: 2, to: weekStart) ?? today,
            content: "Work from home in the am",
            inkColor: .burgundyRed,
            font: .handwritten
        )
    ]

    return WeeklyJournalPageView(
        weekStart: weekStart,
        entries: sampleEntries,
        onEntryTap: { _ in }
    )
}
