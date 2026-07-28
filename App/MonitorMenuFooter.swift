import SwiftUI

struct MonitorMenuFooter: View {
    let refresh: () -> Void
    let quit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button("刷新", systemImage: "arrow.clockwise", action: refresh)
                .keyboardShortcut("r", modifiers: .command)
                .help("刷新本机状态")
            Spacer()
            Button("退出", systemImage: "power", action: quit)
                .keyboardShortcut("q", modifiers: .command)
                .help("退出 AI Monitor")
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }
}
