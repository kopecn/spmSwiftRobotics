// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRobotics",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftRobotics",
            targets: ["SwiftRobotics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/keyvariable/kvSIMD.swift.git", from: "1.1.0")
    ],
    targets: [
        .executableTarget(
            name: "SwiftRoboticVisualizer",
            dependencies: [
                "SwiftRobotics"
            ],
            path: "Sources/SwiftRoboticVisualizer"
        ),
        .target(
            name: "SwiftRobotics",
            dependencies: [
                .product(name: "kvSIMD", package: "kvSIMD.swift")
            ],
            path: "Sources/SwiftRobotics"
        ),
        .testTarget(
            name: "SwiftRoboticsTests",
            dependencies: ["SwiftRobotics"],
            path: "Tests/SwiftRoboticsTests"
        ),
    ]
)
