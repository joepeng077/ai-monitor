import Foundation

public struct MachineVitals: Sendable {
    public let logicalCoreCount: Int
    public let memoryBytes: UInt64
    public let freeDiskBytes: Int64
    public let totalDiskBytes: Int64

    public init(
        logicalCoreCount: Int,
        memoryBytes: UInt64,
        freeDiskBytes: Int64,
        totalDiskBytes: Int64
    ) {
        self.logicalCoreCount = logicalCoreCount
        self.memoryBytes = memoryBytes
        self.freeDiskBytes = freeDiskBytes
        self.totalDiskBytes = totalDiskBytes
    }

    public static func read() -> MachineVitals {
        let values = (try? FileManager.default.attributesOfFileSystem(forPath: "/")) ?? [:]
        let free = (values[.systemFreeSize] as? NSNumber)?.int64Value ?? 0
        let total = (values[.systemSize] as? NSNumber)?.int64Value ?? 0
        return MachineVitals(
            logicalCoreCount: ProcessInfo.processInfo.processorCount,
            memoryBytes: ProcessInfo.processInfo.physicalMemory,
            freeDiskBytes: free,
            totalDiskBytes: total
        )
    }

    public var diskPercentUsed: Int {
        guard totalDiskBytes > 0 else { return 0 }
        return max(0, min(100, Int((1 - Double(freeDiskBytes) / Double(totalDiskBytes)) * 100)))
    }

    public var memoryText: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryBytes), countStyle: .memory)
    }
}
