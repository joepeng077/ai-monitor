import XCTest
@testable import AIMonitorCore

final class MonitorSnapshotTests: XCTestCase {
    func testEmptyPlanIsNotPersisted() {
        let snapshot = MonitorSnapshot(
            source: .workBuddy,
            availability: .ready,
            planLabel: "   ",
            primaryValue: "100",
            detail: "测试"
        )
        XCTAssertNil(snapshot.planLabel)
    }

    func testDefaultProviderStateDoesNotContainCredentials() throws {
        let data = try JSONEncoder().encode(MonitorSnapshot.notConfigured(.claude))
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertFalse(text.localizedCaseInsensitiveContains("token"))
        XCTAssertFalse(text.localizedCaseInsensitiveContains("cookie"))
    }

    func testUnreasonableRawTextIsRejected() {
        let snapshot = MonitorSnapshot(
            source: .codex,
            availability: .ready,
            primaryValue: String(repeating: "a", count: 81),
            detail: "ok"
        )
        XCTAssertFalse(LocalOnlyPolicy.accepts(snapshot: snapshot))
    }
}
