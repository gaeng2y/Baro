import ProjectDescription
import Foundation

let bundlePrefix = "co.gaeng2y.tenniscoach"
let deploymentTargets = DeploymentTargets.iOS("26.0")
let developmentTeam = localDevelopmentTeam()
let firebaseSDKVersion = Version(12, 15, 0)
let composableArchitectureVersion = Version(1, 26, 0)

let project = Project(
    name: "TennisCoach",
    organizationName: "TennisCoach",
    packages: [
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk",
            requirement: .upToNextMajor(from: firebaseSDKVersion)
        ),
        .remote(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            requirement: .upToNextMajor(from: composableArchitectureVersion)
        )
    ],
    settings: .settings(
        base: [
            "SWIFT_VERSION": .string("6.0"),
            "IPHONEOS_DEPLOYMENT_TARGET": .string("26.0"),
            "ENABLE_USER_SCRIPT_SANDBOXING": .string("YES"),
            "CODE_SIGN_STYLE": .string("Automatic"),
            "DEVELOPMENT_TEAM": .string(developmentTeam)
        ]
    ),
    targets: [
        appTarget(),
        frameworkTarget(
            name: "AppFeature",
            sourcePath: "Projects/Feature/AppFeature",
            dependencies: [
                .target(name: "TennisDomain"),
                .target(name: "TennisCore"),
                .target(name: "DesignSystem"),
                .target(name: "OnboardingFeature"),
                .target(name: "MainFeature"),
                .target(name: "TrainingSetupFeature"),
                .target(name: "RecordFeature"),
                .target(name: "SessionSummaryFeature"),
                .target(name: "HistoryFeature"),
                .target(name: "SettingsFeature"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        featureTarget(name: "OnboardingFeature"),
        featureTarget(name: "MainFeature"),
        featureTarget(name: "TrainingSetupFeature"),
        frameworkTarget(
            name: "RecordFeature",
            sourcePath: "Projects/Feature/RecordFeature",
            dependencies: [
                .target(name: "TennisDomain"),
                .target(name: "TennisCore"),
                .target(name: "DesignSystem"),
                .target(name: "CameraPreviewUI"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        featureTarget(name: "SessionSummaryFeature"),
        featureTarget(name: "HistoryFeature"),
        featureTarget(name: "SettingsFeature"),
        frameworkTarget(
            name: "TennisCore",
            sourcePath: "Projects/Core/TennisCore",
            dependencies: [
                .target(name: "TennisDomain")
            ]
        ),
        frameworkTarget(name: "TennisDomain", sourcePath: "Projects/Domain/TennisDomain"),
        frameworkTarget(name: "DesignSystem", sourcePath: "Projects/UserInterface/DesignSystem"),
        frameworkTarget(
            name: "CameraPreviewUI",
            sourcePath: "Projects/UserInterface/CameraPreviewUI",
            dependencies: [
                .target(name: "TennisCore")
            ]
        ),
        testTarget(
            name: "TennisDomainTests",
            sourcePath: "Projects/Domain/TennisDomain",
            dependencies: [
                .target(name: "TennisDomain")
            ]
        ),
        testTarget(
            name: "TennisCoreTests",
            sourcePath: "Projects/Core/TennisCore",
            dependencies: [
                .target(name: "TennisCore"),
                .target(name: "TennisDomain")
            ]
        ),
        testTarget(
            name: "AppFeatureTests",
            sourcePath: "Projects/Feature/AppFeature",
            dependencies: [
                .target(name: "AppFeature"),
                .target(name: "TennisCore"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        testTarget(
            name: "OnboardingFeatureTests",
            sourcePath: "Projects/Feature/OnboardingFeature",
            dependencies: [
                .target(name: "OnboardingFeature"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        testTarget(
            name: "MainFeatureTests",
            sourcePath: "Projects/Feature/MainFeature",
            dependencies: [
                .target(name: "MainFeature"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        testTarget(
            name: "RecordFeatureTests",
            sourcePath: "Projects/Feature/RecordFeature",
            dependencies: [
                .target(name: "RecordFeature"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        testTarget(
            name: "SessionSummaryFeatureTests",
            sourcePath: "Projects/Feature/SessionSummaryFeature",
            dependencies: [
                .target(name: "SessionSummaryFeature"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        testTarget(
            name: "HistoryFeatureTests",
            sourcePath: "Projects/Feature/HistoryFeature",
            dependencies: [
                .target(name: "HistoryFeature"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        testTarget(
            name: "SettingsFeatureTests",
            sourcePath: "Projects/Feature/SettingsFeature",
            dependencies: [
                .target(name: "SettingsFeature"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        ),
        testTarget(
            name: "TrainingSetupFeatureTests",
            sourcePath: "Projects/Feature/TrainingSetupFeature",
            dependencies: [
                .target(name: "TrainingSetupFeature"),
                .target(name: "TennisDomain"),
                .package(product: "ComposableArchitecture")
            ]
        )
    ]
)

func appTarget() -> Target {
    .target(
        name: "TennisCoachApp",
        destinations: .iOS,
        product: .app,
        bundleId: bundlePrefix,
        deploymentTargets: deploymentTargets,
        infoPlist: .extendingDefault(with: [
            "CFBundleDisplayName": "TennisCoach",
            "FirebaseAppDelegateProxyEnabled": false,
            "NSCameraUsageDescription": "TennisCoach analyzes your tennis form on device using the camera.",
            "UISupportedInterfaceOrientations": [
                "UIInterfaceOrientationPortrait",
                "UIInterfaceOrientationLandscapeLeft",
                "UIInterfaceOrientationLandscapeRight"
            ],
            "UILaunchScreen": [:]
        ]),
        sources: ["Projects/App/TennisCoachApp/Sources/**"],
        resources: ["Projects/App/TennisCoachApp/Resources/**"],
        dependencies: [
            .target(name: "AppFeature"),
            .package(product: "FirebaseCore"),
            .package(product: "FirebaseAnalyticsCore")
        ]
    )
}

func localDevelopmentTeam() -> String {
    let manifestDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let path = manifestDirectory
        .appendingPathComponent("Tuist/Local/TeamID.txt")
        .path

    guard
        let content = try? String(contentsOfFile: path, encoding: .utf8)
    else {
        return ""
    }
    return content.trimmingCharacters(in: .whitespacesAndNewlines)
}

func featureTarget(name: String) -> Target {
    frameworkTarget(
        name: name,
        sourcePath: "Projects/Feature/\(name)",
        dependencies: [
            .target(name: "TennisDomain"),
            .target(name: "TennisCore"),
            .target(name: "DesignSystem"),
            .package(product: "ComposableArchitecture")
        ]
    )
}

func frameworkTarget(
    name: String,
    sourcePath: String,
    dependencies: [TargetDependency] = []
) -> Target {
    .target(
        name: name,
        destinations: .iOS,
        product: .framework,
        bundleId: "\(bundlePrefix).\(name)",
        deploymentTargets: deploymentTargets,
        infoPlist: .default,
        sources: ["\(sourcePath)/Sources/**"],
        dependencies: dependencies
    )
}

func testTarget(
    name: String,
    sourcePath: String,
    dependencies: [TargetDependency]
) -> Target {
    .target(
        name: name,
        destinations: .iOS,
        product: .unitTests,
        bundleId: "\(bundlePrefix).\(name)",
        deploymentTargets: deploymentTargets,
        infoPlist: .default,
        sources: ["\(sourcePath)/Tests/**"],
        dependencies: dependencies
    )
}
