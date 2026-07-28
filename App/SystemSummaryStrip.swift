import SwiftUI

struct SystemSummaryStrip: View {
    let vitals: MachineVitals

    var body: some View {
        HStack(spacing: 8) {
            metric(title: "CPU", value: "\(vitals.logicalCoreCount) 核")
            metric(title: "内存", value: vitals.memoryText)
            metric(title: "存储", value: "\(vitals.diskPercentUsed)%")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
                .bold()
                .monospacedDigit()
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title)，\(value)")
    }
}
