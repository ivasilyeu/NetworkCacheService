// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkCacheService",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "NetworkCacheService",
            targets: ["NetworkCacheService"]),
    ],
    targets: [
        .target(
            name: "NetworkCacheService"),
        .testTarget(
            name: "NetworkCacheServiceTests",
            dependencies: ["NetworkCacheService"]),
    ]
)
