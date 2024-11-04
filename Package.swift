// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "CodingKeysGenerator",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "CodingKeysGenerator",
            targets: [
                "CodingKeysGenerator",
                "Shared",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0")
    ],
    targets: [
        .target(name: "Shared"),
        .macro(
            name: "CodingKeysGeneratorMacros",
            dependencies: [
                "Shared",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "CodingKeysGenerator",
            dependencies: [
                "Shared",
                "CodingKeysGeneratorMacros",
            ]
        ),
        .testTarget(
            name: "CodingKeysGeneratorTests",
            dependencies: [
                "CodingKeysGeneratorMacros",
                "Shared",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
