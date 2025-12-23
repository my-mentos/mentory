// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Values",
    products: [
        .library(
            name: "Values",
            targets: ["Values"]
        ),
    ],
    targets: [
        .target(
            name: "Values"
        ),

    ]
)
