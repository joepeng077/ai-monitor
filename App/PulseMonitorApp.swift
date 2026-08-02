import SwiftUI
import WidgetKit

@main
struct PulseMonitorApp: App {
    @State private var vitals = MachineVitals.read()

    var body: some Scene {
        MenuBarExtra("AI Monitor", systemImage: "waveform.path.ecg") {
            MonitorMenu(
                vitals: vitals,
                snapshots: [
                    .notConfigured(.codex),
                    .notConfigured(.claude),
                    .notConfigured(.workBuddy)
                ]
            ) {
                vitals = MachineVitals.read()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .menuBarExtraStyle(.window)
    }
}
