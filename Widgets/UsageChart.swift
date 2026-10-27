import SwiftUI

struct UsageChart: View {
    let points: [WidgetUsageDay]
    let accent: Color
    var isMoney = false
    var compact = false
    private var maximum: Double { max(points.compactMap(\.value).max() ?? 0, 1) }
    private var allMissing: Bool { points.allSatisfy { $0.value == nil } }
    var body: some View {
        VStack(spacing: 5) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    VStack {
                        Spacer()
                        Rectangle().fill(WidgetInk.line).frame(height: 0.5)
                        Spacer()
                        Rectangle().fill(WidgetInk.line).frame(height: 0.5)
                    }
                    HStack(alignment: .bottom, spacing: compact ? 5 : 10) {
                        ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                            VStack(spacing: 4) {
                                if !allMissing {
                                    Text(label(point.value)).font(.system(size: compact ? 7.5 : 8.5, weight: .medium))
                                        .foregroundStyle(WidgetInk.secondary).lineLimit(1).minimumScaleFactor(0.75)
                                }
                                if let value = point.value {
                                    RoundedRectangle(cornerRadius: compact ? 2 : 4)
                                        .fill(LinearGradient(colors: [accent, accent.opacity(0.38)], startPoint: .top, endPoint: .bottom))
                                        .frame(width: compact ? 13 : 17, height: value == 0 ? 1 : max(2, (geometry.size.height - 20) * value / maximum))
                                } else {
                                    Text("—").font(.system(size: 9)).foregroundStyle(WidgetInk.muted).frame(height: 9)
                                }
                            }.frame(maxWidth: .infinity)
                        }
                    }
                    if allMissing {
                        Text("用量未启用").font(.system(size: compact ? 9 : 11, weight: .medium))
                            .foregroundStyle(WidgetInk.muted).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            HStack(spacing: compact ? 5 : 10) {
                ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                    Text(point.date.formatted(.dateTime.month(.twoDigits).day(.twoDigits)))
                        .font(.system(size: compact ? 7.5 : 8, weight: .regular)).foregroundStyle(WidgetInk.muted)
                        .monospacedDigit().lineLimit(1).minimumScaleFactor(0.7).frame(maxWidth: .infinity)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(points.map { $0.date.formatted(date: .abbreviated, time: .omitted) + "，" + ($0.value == nil ? "无数据" : label($0.value)) }.joined(separator: "；"))
    }
    private func label(_ value: Double?) -> String {
        guard let value else { return "—" }
        return isMoney ? (value > 0 && value < 0.01 ? "<0.01" : value.formatted(.number.precision(.fractionLength(2)))) : WidgetText.compact(value)
    }
}

struct UsageChartHeading: View {
    let title: String
    let points: [WidgetUsageDay]
    var isMoney = false
    private var average: Double? {
        let values = points.compactMap(\.value)
        return !points.isEmpty && values.count == points.count ? values.reduce(0, +) / Double(values.count) : nil
    }
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
            Spacer(minLength: 2)
            Text("日均 " + (isMoney ? average.map { $0 > 0 && $0 < 0.01 ? "<0.01" : $0.formatted(.number.precision(.fractionLength(2))) } ?? "—" : WidgetText.compact(average)))
                .font(.system(size: 9, weight: .medium)).foregroundStyle(WidgetInk.muted).monospacedDigit().lineLimit(1)
        }
    }
}
