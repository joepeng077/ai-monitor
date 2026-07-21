import SwiftUI

struct MonitorMenu: View {
    let vitals: MachineVitals
    let refresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("AI Monitor", systemImage: "waveform.path.ecg")
                .font(.headline)
            Text("本机优先 · 无账号凭证 · 无遥测")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()
            metric("CPU 核心", "\\(vitals.logicalCoreCount)")
            metric("物理内存", vitals.memoryText)
            metric("磁盘已用", "\\(vitals.diskPercentUsed)%")

            Divider()
            Text("Codex、Claude 与 WorkBuddy 公开版默认不读取 Cookie、钥匙串或私有登录文件。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button("刷新本机状态", action: refresh)
            Button("退出 AI Monitor") { NSApplication.shared.terminate(nil) }
        }
        .padding(16)
        .frame(width: 310)
    }

    @ViewBuilder
    private func metric(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value).monospacedDigit()
        }
    }
}
