import SwiftUI

struct MonitorMenuHeader: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "waveform.path.ecg")
                .symbolRenderingMode(.hierarchical)
            Text("AI Monitor")
                .font(.headline)
            Spacer()
            Text("本机模式")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("AI Monitor，本机模式")
    }
}
