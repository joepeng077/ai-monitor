import SwiftUI
import WidgetKit

private struct WidgetMoment: TimelineEntry {
    let date: Date
}

private struct MinuteTimeline: TimelineProvider {
    typealias Entry = WidgetMoment

    func placeholder(in context: Context) -> WidgetMoment { WidgetMoment(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (WidgetMoment) -> Void) {
        completion(WidgetMoment(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetMoment>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 5, to: .now) ?? .now
        completion(Timeline(entries: [WidgetMoment(date: .now)], policy: .after(next)))
    }
}

private struct ProviderCard: View {
    let source: MonitorSource
    let symbol: String
    let accent: Color
    let snapshot: MonitorSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: symbol).foregroundStyle(accent)
                Text(source.displayName).font(.headline)
                if let label = snapshot.planLabel {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(.quaternary, in: Capsule())
                }
                Spacer()
            }
            Spacer()
            Text(snapshot.primaryValue).font(.title2.weight(.bold))
            Text(snapshot.detail).font(.caption).foregroundStyle(.secondary)
            Text(snapshot.refreshedAt, style: .time).font(.caption2).foregroundStyle(.tertiary)
        }
        .padding()
        .containerBackground(for: .widget) { Color.black.opacity(0.82) }
    }
}

struct CodexSummaryWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.codex"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MinuteTimeline()) { _ in
            ProviderCard(source: .codex, symbol: "terminal", accent: .indigo, snapshot: .notConfigured(.codex))
        }
        .configurationDisplayName("Codex 总览")
        .description("不读取账号登录态的本地概览卡。")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct ClaudeStatusWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.claude"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MinuteTimeline()) { _ in
            ProviderCard(source: .claude, symbol: "sparkles", accent: .orange, snapshot: .notConfigured(.claude))
        }
        .configurationDisplayName("Claude")
        .description("默认不读取浏览器 Cookie 或登录态。")
        .supportedFamilies([.systemMedium])
    }
}

struct WorkBuddyCreditsWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.workbuddy"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MinuteTimeline()) { _ in
            ProviderCard(source: .workBuddy, symbol: "rectangle.3.group", accent: .mint, snapshot: .notConfigured(.workBuddy))
        }
        .configurationDisplayName("WorkBuddy")
        .description("默认不访问账户令牌或非公开接口。")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct MacVitalsWidget: Widget {
    let kind = "io.github.joepeng077.aimonitor.mac"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MinuteTimeline()) { _ in
            MacCard(vitals: .read())
        }
        .configurationDisplayName("Mac 状态")
        .description("只读取本机公开系统指标。")
        .supportedFamilies([.systemMedium])
    }
}

private struct MacCard: View {
    let vitals: MachineVitals
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Mac 状态", systemImage: "desktopcomputer").font(.headline)
            HStack {
                stat("CPU", "\\(vitals.logicalCoreCount) 核")
                stat("内存", vitals.memoryText)
                stat("存储", "\\(vitals.diskPercentUsed)%")
            }
            Spacer()
            Text("本机采集 · 无网络请求").font(.caption).foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(for: .widget) { Color.black.opacity(0.82) }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3.weight(.semibold)).monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@main
struct MonitorWidgets: WidgetBundle {
    var body: some Widget {
        CodexSummaryWidget()
        ClaudeStatusWidget()
        WorkBuddyCreditsWidget()
        MacVitalsWidget()
    }
}
