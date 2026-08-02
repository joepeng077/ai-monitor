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
    /// A reviewed provider or local sanitized import supplies this display value.
    /// The public core intentionally has no local override or paid-plan fallback.
    public let accountPlan: String?
    public let primaryValue: String
    public let detail: String
    public let refreshedAt: Date

    public init(
        source: MonitorSource,
        availability: MonitorAvailability,
        accountPlan: String? = nil,
        primaryValue: String,
        detail: String,
        refreshedAt: Date = .now
    ) {
        self.source = source
        self.availability = availability
        self.accountPlan = Self.sanitizedAccountPlan(accountPlan)
        self.primaryValue = primaryValue
        self.detail = detail
        self.refreshedAt = refreshedAt
    }

    /// Source-compatible bridge for snapshots created by AI Monitor 1.1.0.
    @available(*, deprecated, renamed: "init(source:availability:accountPlan:primaryValue:detail:refreshedAt:)")
    public init(
        source: MonitorSource,
        availability: MonitorAvailability,
        planLabel: String?,
        primaryValue: String,
        detail: String,
        refreshedAt: Date = .now
    ) {
        self.init(
            source: source,
            availability: availability,
            accountPlan: planLabel,
            primaryValue: primaryValue,
            detail: detail,
            refreshedAt: refreshedAt
        )
    }

    /// Compatibility accessor for integrations compiled against AI Monitor 1.1.0.
    @available(*, deprecated, renamed: "accountPlan")
    public var planLabel: String? { accountPlan }

    public static func notConfigured(_ source: MonitorSource) -> MonitorSnapshot {
        MonitorSnapshot(
            source: source,
            availability: .notConfigured,
            primaryValue: "未启用",
            detail: "仅支持本地脱敏导入"
        )
    }

    private enum CodingKeys: String, CodingKey {
        case source
        case availability
        case accountPlan
        case planLabel
        case primaryValue
        case detail
        case refreshedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decode(MonitorSource.self, forKey: .source)
        availability = try container.decode(MonitorAvailability.self, forKey: .availability)
        let currentPlan = try container.decodeIfPresent(String.self, forKey: .accountPlan)
        let legacyPlan = try container.decodeIfPresent(String.self, forKey: .planLabel)
        accountPlan = Self.sanitizedAccountPlan(currentPlan ?? legacyPlan)
        primaryValue = try container.decode(String.self, forKey: .primaryValue)
        detail = try container.decode(String.self, forKey: .detail)
        refreshedAt = try container.decode(Date.self, forKey: .refreshedAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(source, forKey: .source)
        try container.encode(availability, forKey: .availability)
        try container.encodeIfPresent(accountPlan, forKey: .accountPlan)
        try container.encode(primaryValue, forKey: .primaryValue)
        try container.encode(detail, forKey: .detail)
        try container.encode(refreshedAt, forKey: .refreshedAt)
    }

    private static func sanitizedAccountPlan(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              trimmed.count <= 40,
              trimmed.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) })
        else {
            return nil
        }
        return trimmed
    }
}
