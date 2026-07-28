import SwiftUI

struct MonitorMenu: View {
    let vitals: MachineVitals
    let refresh: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            MonitorMenuHeader()
            Divider()
            SystemSummaryStrip(vitals: vitals)
            Divider()
            VStack(spacing: 0) {
                ProviderStatusRow(source: .codex, systemImage: "terminal")
                Divider().padding(.leading, 42)
                ProviderStatusRow(source: .claude, systemImage: "sparkles")
                Divider().padding(.leading, 42)
                ProviderStatusRow(source: .workBuddy, systemImage: "rectangle.3.group")
            }
            Divider()
            MonitorMenuFooter(refresh: refresh, quit: quitApplication)
        }
        .frame(width: 304)
    }

    private func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
}
