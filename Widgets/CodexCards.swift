import SwiftUI
import WidgetKit

struct CodexFamilyCard: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: PublicWidgetSnapshot
    let now: Date
    var body: some View {
        if family == .systemMedium {
            CodexFiveDayCard(snapshot: snapshot, now: now)
        } else {
            CodexOverviewCard(snapshot: snapshot, now: now)
        }
    }
}

struct CodexOverviewCard: View {
    let snapshot: PublicWidgetSnapshot
    let now: Date
    private var points: [WidgetUsageDay] { snapshot.daySeries(days: 7, now: now, calendar: .current) }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeader(service: .codex, plan: snapshot.accountPlan, refreshedAt: snapshot.refreshedAt,
                         resetCount: snapshot.availableResetCount, showsResetCount: true)
            QuotaDisplayRow(title: "5 小时限额", quota: snapshot.fiveHour, accent: WidgetService.codex.accent)
            QuotaDisplayRow(title: "每周限额", quota: snapshot.weekly, accent: WidgetService.codex.accent)
            Rectangle().fill(WidgetInk.line).frame(height: 0.5).padding(.top, 2)
            UsageChartHeading(title: "近 7 天用量 · Token", points: points).padding(.top, 2)
            UsageChart(points: points, accent: WidgetService.codex.accent).frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 17)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { WidgetSurface(service: .codex) }
    }
}

struct CodexFiveDayCard: View {
    let snapshot: PublicWidgetSnapshot
    let now: Date
    private var points: [WidgetUsageDay] { snapshot.daySeries(days: 5, now: now, calendar: .current) }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeader(service: .codex, plan: snapshot.accountPlan, refreshedAt: snapshot.refreshedAt,
                         resetCount: snapshot.availableResetCount, showsResetCount: true)
            HStack(alignment: .top, spacing: 18) {
                VStack(spacing: 6) {
                    CompactQuotaBlock(title: "5 小时限额", quota: snapshot.fiveHour)
                    CompactQuotaBlock(title: "每周限额", quota: snapshot.weekly)
                }.frame(width: 120)
                VStack(alignment: .leading, spacing: 6) {
                    Text("近 5 天 · Token").font(.system(size: 10, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
                    UsageChart(points: points, accent: WidgetService.codex.accent, compact: true)
                        .frame(maxHeight: .infinity)
                }
            }.frame(maxHeight: .infinity)
        }
        .padding(14).frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { WidgetSurface(service: .codex) }
    }
}

struct CompactQuotaBlock: View {
    let title: String
    let quota: WidgetQuota
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(title).font(.system(size: 9, weight: .medium)).foregroundStyle(WidgetInk.secondary)
                Spacer(minLength: 0)
                Text(WidgetText.percent(quota.remainingPercent)).font(.system(size: 16, weight: .semibold, design: .rounded))
                    .monospacedDigit().foregroundStyle(WidgetInk.primary)
            }
            QuotaSegments(percent: quota.remainingPercent, accent: WidgetService.codex.accent, count: 12)
            Text(WidgetText.reset(quota.resetsAt)).font(.system(size: 7.5, weight: .medium))
                .foregroundStyle(WidgetInk.muted).monospacedDigit().lineLimit(1)
        }.accessibilityElement(children: .combine)
    }
}
