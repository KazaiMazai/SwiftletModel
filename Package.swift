// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftletData",
    products: [
        .library(
            name: "SwiftletData",
            targets: ["SwiftletData"]),
    ],
    dependencies: [
        .package(
             url: "https://github.com/apple/swift-collections.git",
             .upToNextMajor(from: "1.1.0")
           )
    ],
    targets: [
        .target(
            name: "SwiftletData",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]),
        .testTarget(
            name: "SwiftletDataTests",
            dependencies: ["SwiftletData"]),
    ]
)
