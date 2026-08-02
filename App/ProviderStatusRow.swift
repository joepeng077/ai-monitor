import SwiftUI

struct ProviderStatusRow: View {
    let snapshot: MonitorSnapshot
    let systemImage: String

    var body: some View {
        HStack(spacing: 10) {
            Label(snapshot.source.displayName, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 1) {
                Text(statusText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(snapshot.source.displayName)，\(statusText)，\(detailText)")
    }

    private var statusText: String {
        snapshot.accountPlan ?? snapshot.primaryValue
    }

    private var detailText: String {
        if snapshot.accountPlan == nil {
            snapshot.detail
        } else {
            "\(snapshot.primaryValue) · \(snapshot.detail)"
        }
    }
}
