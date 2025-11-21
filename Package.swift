// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRobotics",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftRobotics",
            targets: ["SwiftRobotics"]
        ),
        .library(
            name: "SwiftRoboticsSockets",
            targets: ["SwiftRoboticsSockets"]
        ),
    ],
    dependencies: [
        .package(url: "git@github.com:kopecn/spmFoundationTools.git", branch: "dev"),
        .package(url: "git@github.com:kopecn/spmSocketHandlers.git", branch: "dev"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/keyvariable/kvSIMD.swift.git", from: "1.1.0"),
        .package(url: "https://github.com/OpenCombine/OpenCombine", from: "0.14.0"),
        .package(url: "https://github.com/daikimat/depermaid.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "SwiftRobotics",
            dependencies: [
                .product(name: "FoundationTools", package: "spmFoundationTools"),
                .product(name: "FoundationCommon", package: "spmFoundationTools"),
                .product(name: "FoundationTypes", package: "spmFoundationTools"),
                .product(name: "kvSIMD", package: "kvSIMD.swift"),
            ],
            path: "Sources/SwiftRobotics"
        ),
        .target(
            name: "SwiftRoboticsSockets",
            dependencies: [
                "SwiftRobotics",
                "SwiftRoboticAssets",
                .product(name: "NIOHandler", package: "spmSocketHandlers"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "OpenCombineDispatch", package: "OpenCombine"),
            ],
            path: "Sources/SwiftRoboticsSockets"
        ),
        .target(
            name: "SwiftRoboticAssets",
            path: "Sources/SwiftRoboticAssets",
            resources: [
                .process("Assets")
            ]
        ),
        .testTarget(
            name: "SwiftRoboticsTests",
            dependencies: ["SwiftRobotics"],
            path: "Tests/SwiftRoboticsTests"
        ),
        .testTarget(
            name: "SwiftRoboticsSocketsTests",
            dependencies: [
                "SwiftRoboticsSockets",
                "SwiftRoboticAssets",
                "SwiftRobotics",
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "OpenCombineDispatch", package: "OpenCombine"),
            ],
            path: "Tests/SwiftRoboticsSocketsTests"
        ),
    ]
)
