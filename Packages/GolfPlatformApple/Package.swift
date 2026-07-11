// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version: 6.2

// swift-tools-version: 6.2

// swift-tools-version: 6.2

// swift-tools-version: 6.2

// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GolfPlatformApple",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "GolfPlatformApple",
            targets: ["GolfPlatformApple"]
        )
    ],
    dependencies: [
        .package(
            path: "../GolfClubCore"
        )
    ],
    targets: [
        .target(
            name: "GolfPlatformApple",
            dependencies: [
                .product(
                    name: "GolfCore",
                    package: "GolfClubCore"
                )
            ],
            path: "Sources/GolfPlatformApple"
        ),
        .testTarget(
            name: "GolfPlatformAppleTests",
            dependencies: [
                "GolfPlatformApple",
                .product(
                    name: "GolfCore",
                    package: "GolfClubCore"
                )
            ],
            path: "Tests/GolfPlatformAppleTests"
        )
    ]
)
