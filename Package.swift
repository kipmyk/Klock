// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Klock",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Klock", targets: ["Klock"])
    ],
    targets: [
        .executableTarget(
            name: "Klock",
            dependencies: [],
            path: "Sources",
            swiftSettings: [
                .define("MACOS")
            ])
    ]
)
