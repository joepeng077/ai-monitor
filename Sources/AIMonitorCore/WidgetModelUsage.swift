import Foundation

public struct WidgetModelUsage: Sendable, Equatable {
    public let name: String
    public let value: Double?

    public init(name: String, value: Double?) {
        self.name = WidgetDisplayValidation.text(name, maximumLength: 80) ?? "未命名模型"
        self.value = WidgetDisplayValidation.nonnegative(value)
    }
}
