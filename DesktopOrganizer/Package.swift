// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DesktopOrganizer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "DesktopOrganizer",
            targets: ["DesktopOrganizer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "DesktopOrganizer",
            path: "Sources/DesktopOrganizer",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
