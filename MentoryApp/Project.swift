import ProjectDescription

let project = Project(
    name: "MentoryApp",
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    packages: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/apple/swift-async-algorithms.git", .upToNextMajor(from: "1.1.0")),
    ],
    settings: .settings(
        configurations: [
            .debug(name: "Debug", xcconfig: "Secrets.xcconfig"),
            .release(name: "Release", xcconfig: "Secrets.xcconfig"),
        ]
    ),
    targets: [
        .target(
            name: "MentoryCore",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "cloud.mandooplz.MentoryCore",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .default,
            sources: ["MentoryCore/Sources/**"],
            resources: [],
            dependencies: [
                .project(target: "Values", path: "../MentoryShared"),
                .project(target: "MentoryDBAdapter", path: "../MentoryDB"),
                .project(target: "FirebaseLLMAdapter", path: "../MentoryLLM"),
                .project(target: "iOSReminder", path: "../MentoryDevice"),
                .project(target: "WatchManager", path: "../MentoryDevice"),
            ]
        ),
        .target(
            name: "MentoryApp",
            destinations: .iOS,
            product: .app,
            productName: "Mentory",
            bundleId: "cloud.mandooplz.Mentory",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .extendingDefault(
                with: [
                    "ALAN_API_TOKEN": "$(TOKEN)",
                    "UIApplicationSupportsIndirectInputEvents": true,
                    "UILaunchScreen": [:],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLName": "Mentory",
                            "CFBundleURLSchemes": ["mentory"],
                        ],
                    ],
                ]
            ),
            sources: [
                .glob(
                    "MentoryApp/**/*.swift",
                    excluding: [
                        "MentoryApp/Presentation/TodayBoard/MindAnalyzerView/MindAnalyzerLayout.swift",
                        "MentoryApp/Presentation/TodayBoard/MindAnalyzerView/MindAnalyzerView.swift",
                    ]
                ),
            ],
            resources: [
                "MentoryApp/Assets.xcassets",
                "MentoryApp/GoogleService-Info.plist",
                "Secrets.xcconfig.sample",
            ],
            entitlements: .file(path: "MentoryApp/Mentory.entitlements"),
            dependencies: [
                .target(name: "MentoryCore"),
                .target(name: "MentoryWatchApp"),
                .target(name: "MentoryWidgetExtension"),
                .project(target: "iOSReminder", path: "../MentoryDevice"),
                .project(target: "WatchManager", path: "../MentoryDevice"),
                .project(target: "ImagePicker", path: "../MentoryDevice"),
                .project(target: "Microphone", path: "../MentoryDevice"),
                .package(product: "Collections"),
                .package(product: "AsyncAlgorithms"),
                .project(target: "Values", path: "../MentoryShared"),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=iphoneos*]": "3X262XJF5T",
                    "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "Mentory-Dev-Profile",
                    "CURRENT_PROJECT_VERSION": "2",
                    "MARKETING_VERSION": "25.12",
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
                    "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
                    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
                    "TARGETED_DEVICE_FAMILY": "1",
                    "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                    "INFOPLIST_KEY_NSCameraUsageDescription": "사진 촬영을 위해 카메라 접근 권한이 필요합니다.",
                    "INFOPLIST_KEY_NSMicrophoneUsageDescription": "음성 입력을 위해 마이크 접근 권한이 필요합니다.",
                    "INFOPLIST_KEY_NSSpeechRecognitionUsageDescription": "음성 인식을 위해 권한이 필요합니다.",
                    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
                    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                    "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
                    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                    "INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone": "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight",
                ]
            )
        ),
        .target(
            name: "MentoryTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "cloud.mandooplz.MentoryTests",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .default,
            sources: ["MentoryTests/**/*.swift"],
            resources: [],
            dependencies: [
                .target(name: "MentoryApp"),
                .target(name: "MentoryCore"),
                .project(target: "Values", path: "../MentoryShared"),
                .project(target: "MentoryDBAdapter", path: "../MentoryDB"),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=iphoneos*]": "3X262XJF5T",
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "SWIFT_VERSION": "6.0",
                    "TARGETED_DEVICE_FAMILY": "1",
                    "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "NO",
                    "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/Mentory.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/Mentory",
                    "BUNDLE_LOADER": "$(TEST_HOST)",
                ]
            )
        ),
        .target(
            name: "MentoryWidgetExtension",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "cloud.mandooplz.Mentory.widget",
            deploymentTargets: .iOS("26.1"),
            infoPlist: .extendingDefault(
                with: [
                    "NSExtension": [
                        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
                    ],
                ]
            ),
            sources: ["MentoryWidget/**/*.swift"],
            resources: ["MentoryWidget/Assets.xcassets"],
            entitlements: .file(path: "MentoryWidgetExtension.entitlements"),
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=iphoneos*]": "3X262XJF5T",
                    "PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]": "Mentory-Dev-Widget-Profile",
                    "CURRENT_PROJECT_VERSION": "2",
                    "MARKETING_VERSION": "25.11",
                    "SWIFT_VERSION": "6.0",
                    "TARGETED_DEVICE_FAMILY": "1,2",
                    "ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME": "WidgetBackground",
                    "INFOPLIST_KEY_CFBundleDisplayName": "MentoryWidget",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                ]
            )
        ),
        .target(
            name: "MentoryWatchCore",
            destinations: .watchOS,
            product: .staticFramework,
            bundleId: "cloud.mandooplz.MentoryWatchCore",
            deploymentTargets: .watchOS("26.2"),
            infoPlist: .default,
            sources: ["MentoryWatchCore/Sources/**"],
            resources: [],
            dependencies: []
        ),
        .target(
            name: "MentoryWatchApp",
            destinations: .watchOS,
            product: .app,
            productName: "MentoryWatchApp",
            bundleId: "cloud.mandooplz.Mentory.watch",
            deploymentTargets: .watchOS("26.2"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "MentoryWatch",
                    "WKApplication": true,
                    "WKCompanionAppBundleIdentifier": "cloud.mandooplz.Mentory",
                    "UISupportedInterfaceOrientations": "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown",
                ]
            ),
            sources: ["MentoryWatchApp/**/*.swift"],
            resources: ["MentoryWatchApp/Presentation/Assets.xcassets"],
            entitlements: .file(path: "MentoryWatchApp/MentoryWatchApp.entitlements"),
            dependencies: [
                .target(name: "MentoryWatchCore"),
            ],
            settings: .settings(
                base: [
                    "CODE_SIGN_STYLE": "Manual",
                    "DEVELOPMENT_TEAM[sdk=watchos*]": "3X262XJF5T",
                    "PROVISIONING_PROFILE_SPECIFIER[sdk=watchos*]": "Mentory-Dev-Watch-Profile",
                    "CURRENT_PROJECT_VERSION": "1",
                    "MARKETING_VERSION": "1.0",
                    "SWIFT_VERSION": "6.0",
                    "TARGETED_DEVICE_FAMILY": "4",
                    "STRING_CATALOG_GENERATE_SYMBOLS": "YES",
                ]
            )
        ),
    ],
    additionalFiles: [
        "Mentory.xctestplan",
        "Secrets.xcconfig",
        "Secrets.xcconfig.sample",
        "GoogleService-Info.plist",
        "MentoryWidgetExtension.entitlements",
    ]
)
