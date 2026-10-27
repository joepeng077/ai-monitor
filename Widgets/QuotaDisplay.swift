import SwiftUI

struct QuotaSegments: View {
    let percent: Double?
    let accent: Color
    var count = 20
    private var validPercent: Double? {
        guard let percent, percent.isFinite, (0...100).contains(percent) else { return nil }
        return percent
    }
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<count, id: \.self) { index in
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 2).fill(accent.opacity(validPercent == nil ? 0.055 : 0.13))
                        .overlay(alignment: .leading) {
                            if let validPercent {
                                RoundedRectangle(cornerRadius: 2).fill(accent.gradient)
                                    .frame(width: geometry.size.width * min(1, max(0, validPercent / 100 * Double(count) - Double(index))))
                            }
                        }
                }
            }
        }
        .padding(2).background(.black.opacity(0.14), in: RoundedRectangle(cornerRadius: 4))
        .overlay { RoundedRectangle(cornerRadius: 4).strokeBorder(.white.opacity(0.18), lineWidth: 0.7) }
        .frame(height: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(validPercent == nil ? "额度尚未提供" : "剩余 \(WidgetText.percent(validPercent))")
    }
}

struct QuotaDisplayRow: View {
    let title: String
    let quota: WidgetQuota
    let accent: Color
    var compact = false
    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 3 : 4) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: compact ? 10 : 11, weight: .semibold)).foregroundStyle(WidgetInk.secondary)
                    if !compact {
                        Text(WidgetText.reset(quota.resetsAt)).font(.system(size: 9, weight: .medium)).foregroundStyle(WidgetInk.muted).lineLimit(1)
                    }
                }
                Spacer(minLength: 5)
                Text(WidgetText.percent(quota.remainingPercent))
                    .font(.system(size: compact ? 18 : 21, weight: .semibold, design: .rounded))
                    .monospacedDigit().foregroundStyle(WidgetInk.primary)
            }
            QuotaSegments(percent: quota.remainingPercent, accent: accent)
            if compact {
                Text(WidgetText.reset(quota.resetsAt)).font(.system(size: 8, weight: .medium)).foregroundStyle(WidgetInk.muted).lineLimit(1)
            }
        }.accessibilityElement(children: .combine)
    }
}
