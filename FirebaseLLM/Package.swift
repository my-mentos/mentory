// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseLLM",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "FirebaseLLMAdapter",
            targets: ["FirebaseLLMAdapter"]
        ),
    ],
    dependencies: [
        .package(path: "../Values"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "main")
    ],
    targets: [
        
        .target(
            name: "FirebaseLLMAdapter",
            dependencies: [
                "FirebaseLLMFake",
                .product(name: "FirebaseAI", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAILogic", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk")
            ]
        ),
        
        .target(
            name: "FirebaseLLMFake"
        )

    ]
)
