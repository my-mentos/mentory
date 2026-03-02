import ProjectDescription

let project = Project(
    name: "MentoryLLM",
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    packages: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .branch("main")),
    ],
    targets: [
        .target(
            name: "FirebaseLLMFake",
            destinations: .iOS,
            product: .staticLibrary,
            bundleId: "cloud.mandooplz.FirebaseLLMFake",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/FirebaseLLMFake/**"],
            resources: [],
            dependencies: [
                .project(target: "Values", path: "../MentoryShared"),
            ]
        ),
        .target(
            name: "FirebaseLLMAdapter",
            destinations: .iOS,
            product: .framework,
            bundleId: "cloud.mandooplz.FirebaseLLMAdapter",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/FirebaseLLMAdapter/**"],
            resources: [],
            dependencies: [
                .target(name: "FirebaseLLMFake"),
                .project(target: "Values", path: "../MentoryShared"),
                .package(product: "FirebaseAI"),
                .package(product: "FirebaseAILogic"),
                .package(product: "FirebaseCore"),
            ]
        ),
    ]
)
