// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SwiftletModel",
    platforms: [
       .iOS(.v12),
       .macOS(.v10_15),
       .tvOS(.v12),
       .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SwiftletModel",
            targets: ["SwiftletModel"])
    ],
    dependencies: [
        .package(
             url: "https://github.com/apple/swift-collections.git",
             .upToNextMajor(from: "1.1.0")
           ),
        .package(url: "https://github.com/apple/swift-syntax.git", "509.0.0"..<"600.0.0")
    ],
    targets: [
        .macro(
            name: "SwiftletModelMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "SwiftletModel",
          
            dependencies: [
                "SwiftletModelMacros",
                .product(name: "Collections", package: "swift-collections")
            ]
        ),

        .testTarget(
            name: "SwiftletModelTests",
            dependencies: [
                "SwiftletModel"
            ]
        )
    ]
)
