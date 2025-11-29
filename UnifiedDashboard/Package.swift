// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BrainSAITUnified",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .executable(name: "BrainSAITUnified", targets: ["BrainSAITUnified"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "BrainSAITUnified",
            path: "BrainSAITUnified",
            resources: [
                .process("Assets.xcassets"),
                .process("Preview Content")
            ]
        )
    ]
)
