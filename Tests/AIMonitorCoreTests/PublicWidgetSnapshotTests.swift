import XCTest
@testable import AIMonitorCore

final class PublicWidgetSnapshotTests: XCTestCase {
    func testEmptySnapshotDoesNotInventAccountOrUsageValues() {
        let snapshot = PublicWidgetSnapshot.empty
        XCTAssertNil(snapshot.accountPlan)
        XCTAssertNil(snapshot.refreshedAt)
        XCTAssertNil(snapshot.fiveHour.remainingPercent)
        XCTAssertNil(snapshot.weekly.remainingPercent)
        XCTAssertNil(snapshot.fable.remainingPercent)
        XCTAssertNil(snapshot.availableResetCount)
        XCTAssertTrue(snapshot.dailyUsage.isEmpty)
        XCTAssertNil(snapshot.deepSeek)
        XCTAssertNil(snapshot.credits)
        XCTAssertFalse(LocalOnlyPolicy.permitsAccountAutomation)
    }

    func testZeroIsPreservedAndQuotaWindowsRemainIndependent() {
        let reset = Date(timeIntervalSince1970: 1_800_000_000)
        let snapshot = PublicWidgetSnapshot(
            fiveHour: WidgetQuota(remainingPercent: 0, resetsAt: reset),
            weekly: WidgetQuota(remainingPercent: 45),
            availableResetCount: 0,
            dailyUsage: [WidgetUsageDay(date: reset, value: 0)]
        )
        XCTAssertEqual(snapshot.fiveHour.remainingPercent, 0)
        XCTAssertEqual(snapshot.fiveHour.resetsAt, reset)
        XCTAssertEqual(snapshot.weekly.remainingPercent, 45)
        XCTAssertNil(snapshot.weekly.resetsAt)
        XCTAssertNil(snapshot.fable.remainingPercent)
        XCTAssertEqual(snapshot.availableResetCount, 0)
        XCTAssertEqual(snapshot.dailyUsage.first?.value, 0)
    }

    func testInvalidNumericInputIsUnknownRatherThanClampedOrZero() {
        for invalid in [-1, 101, Double.infinity, -Double.infinity, .nan] {
            XCTAssertNil(WidgetQuota(remainingPercent: invalid).remainingPercent)
        }
        for invalid in [-1, Double.infinity, -Double.infinity, .nan] {
            XCTAssertNil(WidgetUsageDay(date: .now, value: invalid).value)
            XCTAssertNil(DeepSeekDisplayData(balance: invalid).balance)
            XCTAssertNil(CreditDisplayData(remaining: invalid).remaining)
            XCTAssertNil(WidgetModelUsage(name: "Test", value: invalid).value)
        }
        XCTAssertNil(PublicWidgetSnapshot(availableResetCount: -1).availableResetCount)
        XCTAssertEqual(WidgetQuota(remainingPercent: 100).remainingPercent, 100)
        XCTAssertEqual(DeepSeekDisplayData(balance: 0).balance, 0)
        XCTAssertEqual(CreditDisplayData(remaining: 0).remaining, 0)
    }

    func testPlanDisplayPreservesAliasesAndRejectsUnsafeText() {
        XCTAssertEqual(PublicWidgetSnapshot(accountPlan: "  Pro 10x  ").accountPlan, "Pro 10x")
        XCTAssertNil(PublicWidgetSnapshot(accountPlan: " \n ").accountPlan)
        XCTAssertNil(PublicWidgetSnapshot(accountPlan: "Pro\u{0000}10x").accountPlan)
        XCTAssertNil(PublicWidgetSnapshot(accountPlan: String(repeating: "x", count: 41)).accountPlan)
    }

    func testCompleteDaysExcludeTodayAndKeepMissingDaysAcrossYearBoundary() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "Asia/Shanghai"))
        func date(_ day: Int, hour: Int = 12) throws -> Date {
            try XCTUnwrap(calendar.date(from: DateComponents(year: day < 10 ? 2027 : 2026,
                                                             month: day < 10 ? 1 : 12, day: day, hour: hour)))
        }
        let now = try date(2)
        let points = [
            WidgetUsageDay(date: try date(31, hour: 8), value: 5),
            WidgetUsageDay(date: try date(31, hour: 14), value: 7),
            WidgetUsageDay(date: try date(1), value: 0),
            WidgetUsageDay(date: now, value: 99)
        ]
        let series = PublicWidgetSnapshot(dailyUsage: points).daySeries(days: 5, now: now, calendar: calendar)
        XCTAssertEqual(series.map { calendar.component(.day, from: $0.date) }, [28, 29, 30, 31, 1])
        XCTAssertEqual(series.map(\.value), [nil, nil, nil, 7, 0])
        XCTAssertEqual(series.map { calendar.component(.hour, from: $0.date) }, [0, 0, 0, 0, 0])
    }

    func testCompleteDaysUsesCalendarDaysAcrossDaylightSavingTransition() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let now = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 12)))
        let series = WidgetUsageDay.completeDays([], days: 5, now: now, calendar: calendar)
        XCTAssertEqual(series.map { calendar.component(.day, from: $0.date) }, [5, 6, 7, 8, 9])
        XCTAssertEqual(series.map { calendar.component(.hour, from: $0.date) }, [0, 0, 0, 0, 0])
        XCTAssertTrue(series.allSatisfy { $0.value == nil })
        XCTAssertEqual(series[4].date.timeIntervalSince(series[3].date), 23 * 60 * 60)
    }
}
