import SwiftUI

struct DeepSeekCard: View {
    let snapshot: PublicWidgetSnapshot
    let now: Date
    private var data: DeepSeekDisplayData { snapshot.deepSeek ?? DeepSeekDisplayData() }
    private var points: [WidgetUsageDay] { WidgetUsageDay.completeDays(data.dailyCosts, days: 5, now: now, calendar: .current) }
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            WidgetHeader(service: .deepSeek, plan: snapshot.accountPlan, refreshedAt: snapshot.refreshedAt)
            HStack(alignment: .top, spacing: 13) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("可用余额").font(.system(size: 10, weight: .medium)).foregroundStyle(WidgetInk.secondary)
                    Text(WidgetText.money(data.balance, currency: data.currencyCode, permitsNegative: true))
                        .font(.system(size: 24, weight: .semibold, design: .rounded)).monospacedDigit()
                        .foregroundStyle(WidgetInk.primary).lineLimit(1).minimumScaleFactor(0.7)
                    Spacer(minLength: 0)
                    DeepSeekCostRow(title: "V4.1 Flash", value: data.flashMonthCost, currency: data.currencyCode)
                    DeepSeekCostRow(title: "V4 Pro", value: data.proMonthCost, currency: data.currencyCode)
                }.frame(width: 118)
                Rectangle().fill(WidgetInk.line).frame(width: 0.5)
                VStack(alignment: .leading, spacing: 6) {
                    UsageChartHeading(title: "近 5 天 · " + (data.currencyCode == "CNY" ? "元" : data.currencyCode == "USD" ? "美元" : data.currencyCode), points: points, isMoney: true)
                    UsageChart(points: points, accent: WidgetService.deepSeek.accent, isMoney: true, compact: true)
                }
            }.frame(maxHeight: .infinity)
        }
        .padding(14).frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { WidgetSurface(service: .deepSeek) }
    }
}

struct DeepSeekCostRow: View {
    let title: String
    let value: Double?
    let currency: String
    var body: some View {
        HStack(spacing: 3) {
            Text(title).foregroundStyle(WidgetInk.secondary)
            Spacer(minLength: 1)
            Text("本月").foregroundStyle(WidgetInk.muted)
            Text(WidgetText.money(value, currency: currency)).foregroundStyle(WidgetInk.primary).monospacedDigit()
        }.font(.system(size: 8.5, weight: .medium)).lineLimit(1).accessibilityElement(children: .combine)
    }
}
