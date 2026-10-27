import SwiftUI

enum WidgetService {
    case codex, claude, claudeSmall, deepSeek, workBuddy, mac
    var title: String {
        switch self {
        case .codex: "Codex"
        case .claude, .claudeSmall: "Claude"
        case .deepSeek: "DeepSeek"
        case .workBuddy: "WorkBuddy"
        case .mac: "Mac 状态"
        }
    }
    var symbol: String {
        switch self {
        case .codex: "terminal.fill"
        case .claude, .claudeSmall: "sparkle"
        case .deepSeek: "waveform.path"
        case .workBuddy: "square.stack.3d.up.fill"
        case .mac: "chart.bar.fill"
        }
    }
    var accent: Color {
        switch self {
        case .codex: Color(red: 0.64, green: 0.46, blue: 0.94)
        case .claude, .claudeSmall: Color(red: 0.92, green: 0.43, blue: 0.28)
        case .deepSeek: Color(red: 0.34, green: 0.52, blue: 0.97)
        case .workBuddy: Color(red: 0.22, green: 0.75, blue: 0.64)
        case .mac: Color(red: 0.27, green: 0.77, blue: 0.66)
        }
    }
}

enum WidgetInk {
    static let primary = Color.white.opacity(0.94)
    static let secondary = Color.white.opacity(0.65)
    static let muted = Color.white.opacity(0.47)
    static let line = Color.white.opacity(0.10)
}

struct WidgetSurface: View {
    let service: WidgetService
    var body: some View {
        LinearGradient(colors: [Color(red: 0.16, green: 0.16, blue: 0.18), Color(red: 0.085, green: 0.09, blue: 0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay { LinearGradient(colors: [service.accent.opacity(0.10), .clear], startPoint: .topLeading, endPoint: .bottomTrailing) }
    }
}

struct WidgetHeader: View {
    let service: WidgetService
    var plan: String? = nil
    var refreshedAt: Date? = nil
    var resetCount: Int? = nil
    var showsResetCount = false
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: service.symbol).font(.system(size: 17, weight: .semibold))
                .foregroundStyle(service.accent).frame(width: 21).accessibilityHidden(true)
            Text(service.title).font(.system(size: 15, weight: .semibold)).fixedSize()
            if let plan, !plan.isEmpty {
                Text(plan).font(.system(size: 9, weight: .semibold)).lineLimit(1)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(.white.opacity(0.07), in: Capsule()).foregroundStyle(WidgetInk.secondary)
                    .accessibilityLabel("套餐 \(plan)")
            }
            if showsResetCount {
                Text(WidgetText.resetCount(resetCount)).font(.system(size: 8.5, weight: .medium))
                    .monospacedDigit().lineLimit(1).padding(.horizontal, 5).padding(.vertical, 2)
                    .background(service.accent.opacity(0.13), in: Capsule()).foregroundStyle(WidgetInk.secondary)
            }
            Spacer(minLength: 3)
            Text(refreshedAt.map { $0.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)) } ?? "未启用")
                .font(.system(size: 9, weight: .medium)).foregroundStyle(WidgetInk.muted).monospacedDigit().fixedSize()
        }
        .foregroundStyle(WidgetInk.primary).frame(height: 22)
    }
}

enum WidgetText {
    static func percent(_ value: Double?) -> String {
        guard let value, value.isFinite, (0...100).contains(value) else { return "—" }
        return "\(Int(value.rounded()))%"
    }
    static func reset(_ date: Date?) -> String {
        guard let date else { return "重置时间 —" }
        return date.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)) + " 重置"
    }
    static func resetCount(_ count: Int?) -> String {
        guard let count, count >= 0 else { return "可重置 —" }
        return "可重置 \(count) 次"
    }
    static func compact(_ value: Double?) -> String {
        guard let value, value.isFinite, value >= 0 else { return "—" }
        if value >= 100_000_000 { return (value / 100_000_000).formatted(.number.precision(.fractionLength(0...2))) + "亿" }
        if value >= 10_000 { return (value / 10_000).formatted(.number.precision(.fractionLength(0...1))) + "万" }
        return value.formatted(.number.precision(.fractionLength(0...2)))
    }
    static func money(_ value: Double?, currency: String, permitsNegative: Bool = false) -> String {
        guard let value, value.isFinite, permitsNegative || value >= 0 else { return "—" }
        let symbol = currency == "CNY" ? "¥" : currency == "USD" ? "$" : currency + " "
        if value > 0, value < 0.01 { return symbol + "<0.01" }
        return symbol + value.formatted(.number.precision(.fractionLength(2)))
    }
}
