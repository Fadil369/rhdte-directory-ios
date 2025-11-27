// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "RHDTEDirectory",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RHDTEDirectory",
            targets: ["RHDTEDirectory"])
    ],
    dependencies: [
        .package(url: "https://github.com/carekit-apple/CareKit.git", from: "2.1.0"),
        .package(url: "https://github.com/ResearchKit/ResearchKit.git", from: "2.2.0"),
        .package(url: "https://github.com/smart-on-fhir/Swift-SMART.git", from: "4.2.0")
    ],
    targets: [
        .target(
            name: "RHDTEDirectory",
            dependencies: [
                .product(name: "CareKit", package: "CareKit"),
                .product(name: "CareKitUI", package: "CareKit"),
                .product(name: "CareKitStore", package: "CareKit"),
                .product(name: "ResearchKit", package: "ResearchKit"),
                .product(name: "SMART", package: "Swift-SMART")
            ]
        )
    ]
)
