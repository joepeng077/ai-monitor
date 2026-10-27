import Foundation

/// Display-only input to the public widget layouts. Production widgets use `.empty`.
/// This is not an importer, cache, account reader, or network response schema.
public struct PublicWidgetSnapshot: Sendable, Equatable {
    public let accountPlan: String?
    public let refreshedAt: Date?
    public let fiveHour: WidgetQuota
    public let weekly: WidgetQuota
    public let fable: WidgetQuota
    public let availableResetCount: Int?
    public let dailyUsage: [WidgetUsageDay]
    public let deepSeek: DeepSeekDisplayData?
    public let credits: CreditDisplayData?

    public static let empty = PublicWidgetSnapshot()

    public init(
        accountPlan: String? = nil,
        refreshedAt: Date? = nil,
        fiveHour: WidgetQuota = WidgetQuota(),
        weekly: WidgetQuota = WidgetQuota(),
        fable: WidgetQuota = WidgetQuota(),
        availableResetCount: Int? = nil,
        dailyUsage: [WidgetUsageDay] = [],
        deepSeek: DeepSeekDisplayData? = nil,
        credits: CreditDisplayData? = nil
    ) {
        self.accountPlan = WidgetDisplayValidation.text(accountPlan, maximumLength: 40)
        self.refreshedAt = refreshedAt
        self.fiveHour = fiveHour
        self.weekly = weekly
        self.fable = fable
        self.availableResetCount = availableResetCount.flatMap { $0 >= 0 ? $0 : nil }
        self.dailyUsage = dailyUsage
        self.deepSeek = deepSeek
        self.credits = credits
    }

    public func daySeries(days: Int, now: Date, calendar: Calendar) -> [WidgetUsageDay] {
        WidgetUsageDay.completeDays(dailyUsage, days: days, now: now, calendar: calendar)
    }
}
