import SwiftUI
import WidgetKit

struct WorkBuddyFamilyCard: View {
    @Environment(\.widgetFamily) private var family
    let snapshot: PublicWidgetSnapshot
    let now: Date
    var body: some View {
        WorkBuddyCard(snapshot: snapshot, now: now, compact: family == .systemMedium)
    }
}

struct WorkBuddyCard: View {
    let snapshot: PublicWidgetSnapshot
    let now: Date
    var compact = false
    private var data: CreditDisplayData { snapshot.credits ?? CreditDisplayData() }
    private var points: [WidgetUsageDay] { WidgetUsageDay.completeDays(data.dailyCosts, days: 7, now: now, calendar: .current) }
    private var percent: Double? {
        guard let remaining = data.remaining, let total = data.total, total > 0, remaining <= total else { return nil }
        return remaining / total * 100
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WidgetHeader(service: .workBuddy, plan: snapshot.accountPlan, refreshedAt: snapshot.refreshedAt)
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("积分余额").font(.system(size: 11, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
                    Text(data.nextCycle.map { "下一周期 " + $0.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits).hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)) } ?? "下一周期 —")
                        .font(.system(size: 8.5)).foregroundStyle(WidgetInk.muted).lineLimit(1)
                }
                Spacer(minLength: 3)
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(WidgetText.compact(data.remaining)).font(.system(size: 23, weight: .semibold, design: .rounded)).monospacedDigit()
                        Text("积分").font(.system(size: 9)).foregroundStyle(WidgetInk.muted)
                    }.foregroundStyle(WidgetInk.primary)
                    Text("已用 " + WidgetText.compact(data.used) + " 积分")
                        .font(.system(size: 8.5)).foregroundStyle(WidgetInk.muted).monospacedDigit()
                }
            }.accessibilityElement(children: .combine)
            QuotaSegments(percent: percent, accent: WidgetService.workBuddy.accent)
            if !compact {
                Rectangle().fill(WidgetInk.line).frame(height: 0.5).padding(.vertical, 3)
                HStack(alignment: .top, spacing: 16) {
                    CreditDailyList(points: points).frame(maxWidth: .infinity)
                    CreditModelChart(models: data.models).frame(maxWidth: .infinity)
                }.frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .padding(.horizontal, 18).padding(.vertical, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background { WidgetSurface(service: .workBuddy) }
    }
}

struct CreditDailyList: View {
    let points: [WidgetUsageDay]
    private var maximum: Double { max(points.compactMap(\.value).max() ?? 0, 1) }
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("积分消耗 · 近 7 天").font(.system(size: 10.5, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
                .padding(.bottom, 3)
            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                HStack(spacing: 5) {
                    Text(point.date.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))
                        .font(.system(size: 8)).foregroundStyle(WidgetInk.muted).frame(width: 30, alignment: .leading)
                    GeometryReader { geometry in
                        Capsule().fill(.white.opacity(0.035))
                            .overlay(alignment: .leading) {
                                if let value = point.value {
                                    Capsule().fill(WidgetService.workBuddy.accent.opacity(0.65))
                                        .frame(width: value == 0 ? 0 : max(2, geometry.size.width * value / maximum))
                                }
                            }
                    }.frame(height: 5)
                    Text(WidgetText.compact(point.value)).font(.system(size: 8)).foregroundStyle(WidgetInk.secondary)
                        .monospacedDigit().lineLimit(1).frame(minWidth: 10, alignment: .trailing)
                }.frame(height: 11).accessibilityElement(children: .combine)
            }
        }
    }
}

struct CreditModelChart: View {
    let models: [WidgetModelUsage]
    private var total: Double? {
        let values = models.compactMap(\.value)
        guard !models.isEmpty, values.count == models.count else { return nil }
        return values.reduce(0, +)
    }
    private var segments: [CreditModelArc] {
        guard let total, total > 0 else { return [] }
        var cursor = 0.0
        return models.enumerated().map { index, model in
            let start = cursor
            cursor += (model.value ?? 0) / total
            return CreditModelArc(index: index, name: model.name, start: start, end: cursor)
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("模型用量").font(.system(size: 10.5, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
            ZStack {
                Circle().stroke(.white.opacity(0.07), lineWidth: 10)
                ForEach(segments, id: \.index) { segment in
                    Circle().trim(from: segment.start, to: segment.end)
                        .stroke(WidgetService.workBuddy.accent.opacity(max(0.30, 1 - Double(segment.index) * 0.18)), style: StrokeStyle(lineWidth: 10, lineCap: .butt))
                        .rotationEffect(.degrees(-90))
                }
                VStack(spacing: 2) {
                    Text(WidgetText.compact(total)).font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundStyle(WidgetInk.primary)
                    Text("近 7 天").font(.system(size: 8)).foregroundStyle(WidgetInk.muted)
                }
            }.frame(width: 86, height: 86).frame(maxWidth: .infinity)
                .padding(.vertical, 3)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(total == nil ? "模型用量尚未提供" : "模型用量合计 \(WidgetText.compact(total))")
            if models.isEmpty {
                Text("模型数据未启用").font(.system(size: 8.5)).foregroundStyle(WidgetInk.muted)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(Array(models.prefix(3).enumerated()), id: \.offset) { index, model in
                    HStack(spacing: 4) {
                        Circle().fill(WidgetService.workBuddy.accent.opacity(max(0.30, 1 - Double(index) * 0.18)))
                            .frame(width: 4, height: 4).accessibilityHidden(true)
                        Text(model.name).lineLimit(1)
                        Spacer(minLength: 1)
                        Text(WidgetText.compact(model.value)).monospacedDigit()
                    }.font(.system(size: 7.5)).foregroundStyle(WidgetInk.secondary).accessibilityElement(children: .combine)
                }
            }
        }
    }
}

struct CreditModelArc {
    let index: Int
    let name: String
    let start: Double
    let end: Double
}
