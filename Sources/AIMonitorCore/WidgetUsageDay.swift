import Foundation

/// A display value for a calendar day. A missing value differs from measured zero.
public struct WidgetUsageDay: Sendable, Equatable {
    public let date: Date
    public let value: Double?

    public init(date: Date, value: Double?) {
        self.date = date
        self.value = WidgetDisplayValidation.nonnegative(value)
    }

    /// Returns the most recent complete days in the caller's calendar/time zone.
    /// Missing days stay nil; duplicate days use the latest timestamp, not a sum.
    public static func completeDays(
        _ points: [WidgetUsageDay],
        days: Int,
        now: Date,
        calendar: Calendar
    ) -> [WidgetUsageDay] {
        guard (1...366).contains(days) else { return [] }
        let today = calendar.startOfDay(for: now)
        var latest: [Date: WidgetUsageDay] = [:]
        for point in points where point.date < today {
            let day = calendar.startOfDay(for: point.date)
            if let previous = latest[day], previous.date >= point.date { continue }
            latest[day] = point
        }
        return (1...days).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return WidgetUsageDay(date: day, value: latest[day]?.value)
        }
    }
}
