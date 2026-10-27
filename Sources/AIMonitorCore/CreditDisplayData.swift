import Foundation

public struct CreditDisplayData: Sendable, Equatable {
    public let remaining: Double?
    public let used: Double?
    public let total: Double?
    public let nextCycle: Date?
    public let dailyCosts: [WidgetUsageDay]
    public let models: [WidgetModelUsage]

    public init(
        remaining: Double? = nil,
        used: Double? = nil,
        total: Double? = nil,
        nextCycle: Date? = nil,
        dailyCosts: [WidgetUsageDay] = [],
        models: [WidgetModelUsage] = []
    ) {
        self.remaining = WidgetDisplayValidation.nonnegative(remaining)
        self.used = WidgetDisplayValidation.nonnegative(used)
        self.total = WidgetDisplayValidation.nonnegative(total)
        self.nextCycle = nextCycle
        self.dailyCosts = dailyCosts
        self.models = models
    }
}
