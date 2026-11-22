import ProjectDescription
import ProjectDescriptionHelpers

// Keep these flags on both the app and its hosted tests: Swift's dependency
// scanner needs the C++ flag as well as the build setting for CHoshiDicts.
let cxxSettings: SettingsDictionary = [
    "SWIFT_CXX_INTEROPERABILITY_MODE": "default",
    "CLANG_CXX_LANGUAGE_STANDARD": "c++20",
    "CLANG_CXX_LIBRARY": "libc++",
    "OTHER_SWIFT_FLAGS": "$(inherited) -cxx-interoperability-mode=default",
]

// Team ID, bundle IDs and the App Group come from Config/Signing.xcconfig,
// which optionally includes a gitignored Signing.local.xcconfig.
let signingXcconfig: Path = "Config/Signing.xcconfig"
let projectSettings: Settings = {
    var settings = AmgiModule.settings
    settings.configurations = settings.configurations.map { configuration in
        var configuration = configuration
        configuration.xcconfig = signingXcconfig
        return configuration
    }
    return settings
}()

// AnkiClients' `+Live.swift` files hold nothing but `DependencyKey`
// conformances, which only swift-dependencies' runtime cast reaches. Linked as
// a static framework, the linker drops any archive member no symbol pulls in,
// so DeckClient and StatsClient silently fall back to their unimplemented
// test values. Force-load the whole archive.
let forceLoadClients: SettingsDictionary = [
    "OTHER_LDFLAGS": "$(inherited) -force_load $(BUILT_PRODUCTS_DIR)/AnkiClients.framework/AnkiClients",
]

let project = Project(
    name: "AmgiApp",
    options: .options(
        automaticSchemesOptions: .disabled,
        disableSynthesizedResourceAccessors: true
    ),
    settings: projectSettings,
    targets: [
        .target(
            name: "AmgiApp",
            destinations: .iOS,
            product: .app,
            bundleId: "$(AMGI_APP_BUNDLE_ID)",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "Info.plist"),
            sources: [.glob("Sources/**", excluding: ["Sources/Widgets/**", "Sources/Watch/**"])],
            resources: [
                "Resources/Assets.xcassets",
                "Resources/AppIcons/**",
                .folderReference(path: "Resources/mathjax"),
                .folderReference(path: "Resources/Review"),
                .folderReference(path: "Resources/Fonts"),
                .folderReference(path: "Resources/EPUBReader"),
            ],
            entitlements: .file(path: "AmgiApp.entitlements"),
            dependencies: [
                .project(target: "RootFeature", path: .relativeToRoot("AmgiFeatures")),
                .project(target: "IntentsFeature", path: .relativeToRoot("AmgiFeatures")),
                .sdk(name: "WidgetKit", type: .framework),
                .target(name: "AmgiWidget"),
            ],
            settings: .settings(base: cxxSettings.merging([
                "ASSETCATALOG_COMPILER_APPICON_NAME": "Dojang",
                "ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES[sdk=iphone*]": "Handwritten DeepTeal Midnight Celadon Persimmon DojangHanzi HandwrittenHanzi DeepTealHanzi MidnightHanzi CeladonHanzi PersimmonHanzi",
            ]) { _, value in value }.merging(forceLoadClients) { _, value in value })
        ),
        .target(
            name: "AmgiWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "$(AMGI_APP_BUNDLE_ID).widget",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "Sources/Widgets/Info.plist"),
            sources: ["Sources/Widgets/**"],
            entitlements: .file(path: "AmgiWidget.entitlements"),
            dependencies: [
                .project(target: "WidgetFeature", path: .relativeToRoot("AmgiFeatures")),
                .sdk(name: "WidgetKit", type: .framework),
                .sdk(name: "SwiftUI", type: .framework),
            ]
        ),
        .target(
            name: "AmgiWatchApp",
            destinations: [.appleWatch],
            product: .app,
            bundleId: "$(AMGI_APP_BUNDLE_ID).watch",
            deploymentTargets: .watchOS("11.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "WKCompanionAppBundleIdentifier": "$(AMGI_APP_BUNDLE_ID)",
            ]),
            sources: ["Sources/Watch/**"],
            dependencies: [
                .project(target: "AnkiKit", path: .relativeToRoot(".")),
                .project(target: "Theme", path: .relativeToRoot("AmgiUI")),
                .project(target: "UI", path: .relativeToRoot("AmgiUI")),
                .project(target: "AnkiServices", path: .relativeToRoot(".")),
                .project(target: "AnkiClients", path: .relativeToRoot(".")),
                .project(target: "AnkiSync", path: .relativeToRoot(".")),
                .project(target: "AnkiBackend", path: .relativeToRoot(".")),
                .project(target: "AmgiCardWeb", path: .relativeToRoot(".")),
                .project(target: "AppCore", path: .relativeToRoot("AmgiFeatures")),
                .project(target: "StatsCharts", path: .relativeToRoot("AmgiFeatures")),
                .project(target: "ReviewCore", path: .relativeToRoot("AmgiFeatures")),
                .project(target: "WatchFeature", path: .relativeToRoot("AmgiFeatures")),
                .external(name: "SwiftNavigation"),
                .external(name: "Sharing"),
            ],
            settings: .settings(base: [
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "SKIP_INSTALL": "YES",
            ].merging(forceLoadClients) { _, value in value })
        ),
        .target(
            name: "AmgiAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "$(AMGI_APP_BUNDLE_ID)Tests",
            deploymentTargets: .iOS("18.0"),
            sources: ["Tests/AmgiAppTests/**"],
            resources: ["Tests/AmgiAppTests/*.mp3", "Tests/AmgiAppTests/*.zip"],
            dependencies: [.target(name: "AmgiApp")],
            settings: .settings(base: cxxSettings)
        ),
        .target(
            name: "AmgiAppUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "$(AMGI_APP_BUNDLE_ID)UITests",
            deploymentTargets: .iOS("18.0"),
            sources: ["Tests/AmgiAppUITests/**"],
            dependencies: [.target(name: "AmgiApp")]
        ),
    ],
    schemes: [
        .scheme(
            name: "AmgiWatchApp",
            buildAction: .buildAction(targets: ["AmgiWatchApp"]),
            runAction: .runAction(configuration: .debug),
            archiveAction: .archiveAction(configuration: .release),
            profileAction: .profileAction(configuration: .release),
            analyzeAction: .analyzeAction(configuration: .debug)
        ),
    ],
    resourceSynthesizers: []
)
