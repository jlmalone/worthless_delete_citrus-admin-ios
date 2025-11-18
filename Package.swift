// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CitrusAdmin",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CitrusAdmin",
            targets: ["CitrusAdmin"]
        ),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "CitrusAdmin",
            dependencies: [],
            path: "CitrusAdmin"
        ),
    ]
)
