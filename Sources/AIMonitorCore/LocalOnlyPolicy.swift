import Foundation

public enum LocalOnlyPolicy {
    /// Public builds must start in this state. Network requests and login-state
    /// readers are deliberately outside the first open-source release.
    public static let permitsAccountAutomation = false

    public static func accepts(snapshot: MonitorSnapshot) -> Bool {
        snapshot.primaryValue.count <= 80 && snapshot.detail.count <= 160
    }
}
