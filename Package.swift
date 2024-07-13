// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyModel",
    products: [
        .library(
            name: "SwiftyModel",
            targets: ["SwiftyModel"]),
    ],
    dependencies: [
        .package(
             url: "https://github.com/apple/swift-collections.git",
             .upToNextMajor(from: "1.1.0")
           )
    ],
    targets: [
        .target(
            name: "SwiftyModel",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]),
        .testTarget(
            name: "SwiftyModelTests",
            dependencies: ["SwiftyModel"]),
    ]
)
