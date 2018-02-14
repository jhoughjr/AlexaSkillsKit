// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "AlexaSkillsKit",
    products: [
        .library(name: "AlexaSkillsKit", targets: ["AlexaSkillsKit"]),
    ],
    targets: [
        .target(name: "AlexaSkillsKit", exclude: ["Samples"]),
        .testTarget(name: "AlexaSkillsKitTests", dependencies: ["AlexaSkillsKit"])
    ]
)
