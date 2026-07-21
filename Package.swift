// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AIMonitorCore",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AIMonitorCore", targets: ["AIMonitorCore"])
    ],
    targets: [
        .target(name: "AIMonitorCore", path: "Sources/AIMonitorCore"),
        .testTarget(name: "AIMonitorCoreTests", dependencies: ["AIMonitorCore"], path: "Tests/AIMonitorCoreTests")
    ]
)
