import ProjectDescription

let project = Project(
    name: "MentoryShared",
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    targets: [
        .target(
            name: "Values",
            destinations: .iOS,
            product: .framework,
            bundleId: "cloud.mandooplz.Values",
            deploymentTargets: .iOS("26.1"),
            sources: ["Sources/Values/**"],
            resources: [],
            dependencies: []
        ),
    ]
)
