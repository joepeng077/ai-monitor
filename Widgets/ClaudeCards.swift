import SwiftUI

struct ClaudeSmallCard: View {
    let snapshot: PublicWidgetSnapshot
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "sparkle").foregroundStyle(WidgetService.claude.accent).accessibilityHidden(true)
                Text("Claude").font(.system(size: 12, weight: .semibold))
                Spacer(minLength: 0)
                Text(snapshot.refreshedAt == nil ? "未启用" : "已更新")
                    .font(.system(size: 7)).foregroundStyle(WidgetInk.muted)
            }.frame(height: 17)
            SmallQuotaPanel(title: "5 小时", quota: snapshot.fiveHour, accent: Color(red: 0.96, green: 0.51, blue: 0.65))
            SmallQuotaPanel(title: "每周", quota: snapshot.weekly, accent: Color(red: 0.52, green: 0.82, blue: 0.32))
        }
        .padding(10).frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(WidgetInk.primary).background { WidgetSurface(service: .claudeSmall) }
    }
}

struct SmallQuotaPanel: View {
    let title: String
    let quota: WidgetQuota
    let accent: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline) {
                Text(WidgetText.percent(quota.remainingPercent)).font(.system(size: 21, weight: .semibold, design: .rounded)).monospacedDigit()
                Spacer(minLength: 3)
                Text(title).font(.system(size: 8, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
            }
            GeometryReader { geometry in
                Capsule().fill(accent.opacity(0.12))
                    .overlay(alignment: .leading) {
                        if let value = quota.remainingPercent {
                            Capsule().fill(accent).frame(width: geometry.size.width * value / 100)
                        }
                    }
            }.frame(height: 5).accessibilityHidden(true)
            Text(WidgetText.reset(quota.resetsAt)).font(.system(size: 7.5)).foregroundStyle(WidgetInk.muted).lineLimit(1)
        }
        .padding(.horizontal, 7).padding(.vertical, 5)
        .background(Color(red: 0.025, green: 0.095, blue: 0.13), in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
    }
}

struct ClaudeDualCard: View {
    let snapshot: PublicWidgetSnapshot
    var body: some View {
        VStack(spacing: 8) {
            WidgetHeader(service: .claude, plan: snapshot.accountPlan, refreshedAt: snapshot.refreshedAt)
            QuotaDisplayRow(title: "5 小时限额", quota: snapshot.fiveHour, accent: WidgetService.claude.accent)
            QuotaDisplayRow(title: "每周限额", quota: snapshot.weekly, accent: WidgetService.claude.accent)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { WidgetSurface(service: .claude) }
    }
}

struct ClaudeOverviewCard: View {
    let snapshot: PublicWidgetSnapshot
    let now: Date
    private var points: [WidgetUsageDay] { snapshot.daySeries(days: 7, now: now, calendar: .current) }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            WidgetHeader(service: .claude, plan: snapshot.accountPlan, refreshedAt: snapshot.refreshedAt,
                         resetCount: snapshot.availableResetCount, showsResetCount: true)
            QuotaDisplayRow(title: "5 小时限额", quota: snapshot.fiveHour, accent: WidgetService.claude.accent)
            QuotaDisplayRow(title: "每周限额", quota: snapshot.weekly, accent: WidgetService.claude.accent)
            FableQuotaLine(quota: snapshot.fable)
            UsageChartHeading(title: "近 7 天用量 · Token", points: points).padding(.top, 8)
            UsageChart(points: points, accent: WidgetService.claude.accent)
                .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 18).padding(.top, 14).padding(.bottom, 17)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { WidgetSurface(service: .claude) }
    }
}

struct FableQuotaLine: View {
    let quota: WidgetQuota
    var body: some View {
        HStack(spacing: 5) {
            Text("Fable 专属").font(.system(size: 9.5, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
            Text(WidgetText.percent(quota.remainingPercent)).font(.system(size: 11, weight: .semibold))
                .foregroundStyle(quota.remainingPercent == nil ? WidgetInk.muted : WidgetService.claude.accent)
            Spacer(minLength: 2)
            Text(WidgetText.reset(quota.resetsAt)).font(.system(size: 8.5)).foregroundStyle(WidgetInk.muted).lineLimit(1)
        }.frame(height: 17).accessibilityElement(children: .combine)
    }
}
