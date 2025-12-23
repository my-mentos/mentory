// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MentoryDB",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "MentoryDBAdapter",
            targets: ["MentoryDBAdapter"]
        ),
    ],
    dependencies: [
        .package(path: "../Values"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.3.0"))
    ],
    targets: [
        .target(
            name: "MentoryDB",
            dependencies: [
                .product(name: "Values", package: "Values")
            ]
        ),
        
        .target(
            name: "MentoryDBAdapter",
            dependencies: [
                .product(name: "Values", package: "Values"),
                "MentoryDB",
                "MentoryDBFake"
            ]
        ),
        
        .target(
            name: "MentoryDBFake",
            dependencies: [
                .product(name: "Values", package: "Values"),
                .product(name: "Collections", package: "swift-collections")
            ]
        )
    ]
)
