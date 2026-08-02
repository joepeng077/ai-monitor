import XCTest
@testable import AIMonitorCore

final class MonitorSnapshotTests: XCTestCase {
    func testEmptyPlanIsNotPersisted() {
        let snapshot = MonitorSnapshot(
            source: .workBuddy,
            availability: .ready,
            accountPlan: "   ",
            primaryValue: "100",
            detail: "测试"
        )
        XCTAssertNil(snapshot.accountPlan)
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

    func testFreePlanRoundTripsWithoutPaidFallback() throws {
        let snapshot = MonitorSnapshot(
            source: .codex,
            availability: .ready,
            accountPlan: "Free",
            primaryValue: "94%",
            detail: "每周剩余"
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(MonitorSnapshot.self, from: data)
        XCTAssertEqual(decoded.accountPlan, "Free")
        XCTAssertFalse(try XCTUnwrap(String(data: data, encoding: .utf8)).contains("planLabel"))
    }

    func testLegacyPlanLabelStillDecodes() throws {
        let json = #"{"source":"codex","availability":"ready","planLabel":"Free","primaryValue":"94%","detail":"每周剩余","refreshedAt":0}"#
        let decoded = try JSONDecoder().decode(MonitorSnapshot.self, from: Data(json.utf8))
        XCTAssertEqual(decoded.accountPlan, "Free")
    }

    func testUnsafePlanTextIsRejected() {
        let tooLong = MonitorSnapshot(
            source: .codex,
            availability: .ready,
            accountPlan: String(repeating: "x", count: 41),
            primaryValue: "--",
            detail: "测试"
        )
        let controlCharacter = MonitorSnapshot(
            source: .codex,
            availability: .ready,
            accountPlan: "Free\u{0000}",
            primaryValue: "--",
            detail: "测试"
        )

        XCTAssertNil(tooLong.accountPlan)
        XCTAssertNil(controlCharacter.accountPlan)
    }
}
