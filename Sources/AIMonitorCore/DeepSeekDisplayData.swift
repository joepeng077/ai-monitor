import Foundation

/// Presentation values only; no API credentials or account identifiers.
public struct DeepSeekDisplayData: Sendable, Equatable {
    public let balance: Double?
    public let currencyCode: String
    public let flashMonthCost: Double?
    public let proMonthCost: Double?
    public let dailyCosts: [WidgetUsageDay]

    public init(
        balance: Double? = nil,
        currencyCode: String = "CNY",
        flashMonthCost: Double? = nil,
        proMonthCost: Double? = nil,
        dailyCosts: [WidgetUsageDay] = []
    ) {
        self.balance = WidgetDisplayValidation.nonnegative(balance)
        self.currencyCode = WidgetDisplayValidation.text(currencyCode, maximumLength: 8) ?? "CNY"
        self.flashMonthCost = WidgetDisplayValidation.nonnegative(flashMonthCost)
        self.proMonthCost = WidgetDisplayValidation.nonnegative(proMonthCost)
        self.dailyCosts = dailyCosts
    }
}
