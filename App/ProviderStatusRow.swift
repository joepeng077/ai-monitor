import SwiftUI

struct ProviderStatusRow: View {
    let source: MonitorSource
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Label(source.displayName, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 1) {
                Text("未启用")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("账户数据保持关闭")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(source.displayName)，未启用，公开版不会读取账户登录态")
    }
}
