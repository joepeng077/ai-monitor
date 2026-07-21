import Foundation

public enum MonitorSource: String, Codable, CaseIterable, Sendable {
    case codex
    case claude
    case workBuddy
    case mac

    public var displayName: String {
        switch self {
        case .codex: "Codex"
        case .claude: "Claude"
        case .workBuddy: "WorkBuddy"
        case .mac: "Mac Status"
        }
    }
}

public enum MonitorAvailability: String, Codable, Sendable {
    case ready
    case notConfigured
    case unavailable
}

/// This is the entire public cache schema. It intentionally has no account ID,
/// path, cookie, token, raw response, or other authentication field.
public struct MonitorSnapshot: Codable, Sendable, Equatable {
    public let source: MonitorSource
    public let availability: MonitorAvailability
    public let planLabel: String?
    public let primaryValue: String
    public let detail: String
    public let refreshedAt: Date

    public init(
        source: MonitorSource,
        availability: MonitorAvailability,
        planLabel: String? = nil,
        primaryValue: String,
        detail: String,
        refreshedAt: Date = .now
    ) {
        self.source = source
        self.availability = availability
        self.planLabel = Self.sanitizedPlanLabel(planLabel)
        self.primaryValue = primaryValue
        self.detail = detail
        self.refreshedAt = refreshedAt
    }

    public static func notConfigured(_ source: MonitorSource) -> MonitorSnapshot {
        MonitorSnapshot(
            source: source,
            availability: .notConfigured,
            primaryValue: "未启用",
            detail: "仅支持本地脱敏导入"
        )
    }

    private static func sanitizedPlanLabel(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= 40 else { return nil }
        return trimmed
    }
}
