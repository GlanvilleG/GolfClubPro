// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 6.2

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GolfClubCore",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "GolfCore",
            targets: ["GolfCore"]
        )
    ],
    targets: [
        .target(
            name: "GolfCore",
            path: "Sources/GolfCore",
            swiftSettings: [
                .enableUpcomingFeature(
                    "ApproachableConcurrency"
                )
            ]
        ),
        .testTarget(
            name: "GolfCoreTests",
            dependencies: [
                "GolfCore"
            ],
            path: "Tests/GolfCoreTests",
            swiftSettings: [
                .enableUpcomingFeature(
                    "ApproachableConcurrency"
                )
            ]
        )
    ]
)
