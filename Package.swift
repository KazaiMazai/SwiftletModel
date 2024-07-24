// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftletModel",
    products: [
        .library(
            name: "SwiftletModel",
            targets: ["SwiftletModel"]),
    ],
    dependencies: [
        .package(
             url: "https://github.com/apple/swift-collections.git",
             .upToNextMajor(from: "1.1.0")
           )
    ],
    targets: [
        .target(
            name: "SwiftletModel",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]),
        .testTarget(
            name: "SwiftletModelTests",
            dependencies: ["SwiftletModel"]),
    ]
)
