// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "RHDTEDirectory",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "RHDTEDirectory",
            targets: ["RHDTEDirectory"])
    ],
    dependencies: [
        // CareKit 3.1.7 - Latest stable version with Swift 5 support
        .package(url: "https://github.com/carekit-apple/CareKit.git", from: "3.1.0"),
        // ResearchKit 3.0.1 - Latest stable version
        .package(url: "https://github.com/ResearchKit/ResearchKit.git", from: "3.0.0"),
        // Swift-SMART 4.2.0 - FHIR R4 support
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
            ],
            path: "."
        )
    ]
)
