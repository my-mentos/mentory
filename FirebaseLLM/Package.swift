// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseLLM",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FirebaseLLM",
            targets: ["FirebaseLLM"]
        ),
    ],
    dependencies: [
        .package(path: "./Values")
    ],
    targets: [
        .target(
            name: "FirebaseLLM"
        ),

    ]
)
