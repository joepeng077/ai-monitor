import SwiftUI

struct MacVitalsCard: View {
    let vitals: MachineVitals
    let now: Date
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WidgetHeader(service: .mac, refreshedAt: now)
            HStack(alignment: .top, spacing: 12) {
                MacMetricColumn(title: "CPU", value: "\(vitals.logicalCoreCount)", detail: "逻辑核心", accent: .cyan)
                Rectangle().fill(WidgetInk.line).frame(width: 0.5)
                MacMetricColumn(title: "内存", value: vitals.memoryText, detail: "物理内存总量", accent: WidgetService.mac.accent)
                Rectangle().fill(WidgetInk.line).frame(width: 0.5)
                MacMetricColumn(title: "存储", value: ByteCountFormatter.string(fromByteCount: vitals.freeDiskBytes, countStyle: .file),
                                detail: "系统盘可用", accent: .orange)
            }.frame(maxHeight: .infinity)
            Text("本机系统指标").font(.system(size: 8)).foregroundStyle(WidgetInk.muted)
        }
        .padding(15).frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { WidgetSurface(service: .mac) }
    }
}

struct MacMetricColumn: View {
    let title: String
    let value: String
    let detail: String
    let accent: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 10, weight: .medium)).foregroundStyle(WidgetInk.secondary)
            Text(value).font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(WidgetInk.primary).monospacedDigit().lineLimit(1).minimumScaleFactor(0.65)
            Rectangle().fill(accent).frame(width: 20, height: 2).accessibilityHidden(true)
            Text(detail).font(.system(size: 8)).foregroundStyle(WidgetInk.muted).lineLimit(1)
        }.frame(maxWidth: .infinity, alignment: .leading).accessibilityElement(children: .combine)
    }
}
