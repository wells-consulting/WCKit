// swift-tools-version:5.6

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
        .target(
            name: "WCKit",
            path: "WCKit"
        )
    ]
)
