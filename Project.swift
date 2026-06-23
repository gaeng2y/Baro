import ProjectDescription
import Foundation

let bundlePrefix = "co.gaeng2y.tenniscoach"
let deploymentTargets = DeploymentTargets.iOS("17.0")
let developmentTeam = localDevelopmentTeam()

let project = Project(
    name: "TennisCoach",
    organizationName: "TennisCoach",
    settings: .settings(
        base: [
            "SWIFT_VERSION": .string("6.0"),
            "IPHONEOS_DEPLOYMENT_TARGET": .string("17.0"),
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
                .target(name: "SettingsFeature")
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
                .target(name: "CameraPreviewUI")
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
        )
    ]
)

func appTarget() -> Target {
    .target(
        name: "TennisCoachApp",
        destinations: .iOS,
        product: .app,
        bundleId: "\(bundlePrefix).app",
        deploymentTargets: deploymentTargets,
        infoPlist: .extendingDefault(with: [
            "CFBundleDisplayName": "TennisCoach",
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
            .target(name: "AppFeature")
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
            .target(name: "DesignSystem")
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
