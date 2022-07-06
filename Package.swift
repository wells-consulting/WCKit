// swift-tools-version:5.0

// Copyright © 2022 Wells Consulting LLC. All rights reserved.

import PackageDescription

let package = Package(
    name: "WCKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v15)
    ],
    products: [
        .library(
            name: "WCKit",
            targets: ["WCKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "WCKit",
            path: "WCKit",
            sources: ["Core", "Utils", "Views"]
        )
    ]
)
