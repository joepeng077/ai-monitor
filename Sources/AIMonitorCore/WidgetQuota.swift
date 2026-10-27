import Foundation

/// An independent quota window. Unknown values are never converted to zero.
public struct WidgetQuota: Sendable, Equatable {
    public let remainingPercent: Double?
    public let resetsAt: Date?

    public init(remainingPercent: Double? = nil, resetsAt: Date? = nil) {
        if let value = WidgetDisplayValidation.nonnegative(remainingPercent), value <= 100 {
            self.remainingPercent = value
        } else {
            self.remainingPercent = nil
        }
        self.resetsAt = resetsAt
    }
}
