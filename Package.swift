// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SMA",
    products: [
        .library(
            name: "SMA",
            targets: ["SMA"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SMA",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
            ]
        ),
        .testTarget(
            name: "SMATests",
            dependencies: ["SMA"]),
    ]
)
