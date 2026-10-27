import SwiftUI
import WidgetKit

struct PublicWidgetMoment: TimelineEntry { let date: Date }

struct PublicWidgetTimeline: TimelineProvider {
    func placeholder(in context: Context) -> PublicWidgetMoment { .init(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (PublicWidgetMoment) -> Void) { completion(.init(date: .now)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PublicWidgetMoment>) -> Void) {
        let now = Date.now
        completion(Timeline(entries: [.init(date: now)], policy: .after(now.addingTimeInterval(300))))
    }
}

struct CodexSummaryWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.codex"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { entry in
            CodexFamilyCard(snapshot: .empty, now: entry.date)
                .containerBackground(for: .widget) { WidgetSurface(service: .codex) }
        }
        .configurationDisplayName("Codex 总览")
        .description("5 小时与每周额度，以及最近完整自然日的 Token 用量。账户读取未启用。")
        .supportedFamilies([.systemMedium, .systemLarge]).contentMarginsDisabled()
    }
}

struct CodexFiveDayWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.codex.fiveDay"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { entry in
            CodexFiveDayCard(snapshot: .empty, now: entry.date)
                .containerBackground(for: .widget) { WidgetSurface(service: .codex) }
        }
        .configurationDisplayName("Codex 双限额与五日用量")
        .description("双额度、各自重置时间与近 5 天 Token 用量。账户读取未启用。")
        .supportedFamilies([.systemMedium]).contentMarginsDisabled()
    }
}

struct ClaudeStatusWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.claude"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { _ in
            ClaudeDualCard(snapshot: .empty)
                .containerBackground(for: .widget) { WidgetSurface(service: .claude) }
        }
        .configurationDisplayName("Claude 双额度")
        .description("两行电池显示 5 小时与每周剩余额度。账户读取未启用。")
        .supportedFamilies([.systemMedium]).contentMarginsDisabled()
    }
}

struct ClaudeSmallWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.claude.small"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { _ in
            ClaudeSmallCard(snapshot: .empty)
                .containerBackground(for: .widget) { WidgetSurface(service: .claudeSmall) }
        }
        .configurationDisplayName("Claude 用量")
        .description("紧凑显示两组额度及重置时间。账户读取未启用。")
        .supportedFamilies([.systemSmall]).contentMarginsDisabled()
    }
}

struct ClaudeOverviewWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.claude.overview"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { entry in
            ClaudeOverviewCard(snapshot: .empty, now: entry.date)
                .containerBackground(for: .widget) { WidgetSurface(service: .claude) }
        }
        .configurationDisplayName("Claude 总览")
        .description("双额度、Fable 专属额度、重置次数与 7 日 Token 用量。账户读取未启用。")
        .supportedFamilies([.systemLarge]).contentMarginsDisabled()
    }
}

struct DeepSeekBalanceWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.deepseek"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { entry in
            DeepSeekCard(snapshot: .empty, now: entry.date)
                .containerBackground(for: .widget) { WidgetSurface(service: .deepSeek) }
        }
        .configurationDisplayName("DeepSeek 余额与五日消耗")
        .description("余额、Flash 与 Pro 月费用、最近 5 天费用。账户读取未启用。")
        .supportedFamilies([.systemMedium]).contentMarginsDisabled()
    }
}

struct WorkBuddyCreditsWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.workbuddy"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { entry in
            WorkBuddyFamilyCard(snapshot: .empty, now: entry.date)
                .containerBackground(for: .widget) { WidgetSurface(service: .workBuddy) }
        }
        .configurationDisplayName("WorkBuddy 用量")
        .description("积分余额、近 7 天消耗与模型分布。账户读取未启用。")
        .supportedFamilies([.systemMedium, .systemLarge]).contentMarginsDisabled()
    }
}

struct MacVitalsWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.mac"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PublicWidgetTimeline()) { entry in
            MacVitalsCard(vitals: .read(), now: entry.date)
                .containerBackground(for: .widget) { WidgetSurface(service: .mac) }
        }
        .configurationDisplayName("Mac 状态")
        .description("查看 CPU 核心数、总内存与系统盘可用空间。")
        .supportedFamilies([.systemMedium]).contentMarginsDisabled()
    }
}

@main
struct MonitorWidgets: WidgetBundle {
    var body: some Widget {
        MacVitalsWidget()
        DeepSeekBalanceWidget()
        WorkBuddyCreditsWidget()
        ClaudeSmallWidget()
        ClaudeStatusWidget()
        ClaudeOverviewWidget()
        CodexSummaryWidget()
        CodexFiveDayWidget()
    }
}
