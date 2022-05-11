// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PodToBUILD",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0")

    ],
    targets: [
        .executableTarget(name: "Compiler", dependencies: ["PodToBUILD"]),
        .executableTarget(name: "RepoTools", dependencies: ["RepoToolsCore"]),
        .target(name: "PodToBUILD", dependencies: ["ObjcSupport", "Yams"]),
        .target(name: "ObjcSupport"),
        .target(name: "RepoToolsCore", dependencies: ["PodToBUILD", "SwiftCheck"]),
        .testTarget(name: "PodToBUILDTests", dependencies: ["RepoToolsCore", "SwiftCheck"]),
        .testTarget(
            name: "BuildTests",
            dependencies:  ["RepoToolsCore", "SwiftCheck"],
            resources: [.copy("Examples/PodSpecs/*.podspec.json")]
        ),
    ]
)


//# PodToBUILD is a core library enabling Starlark code generation
//
//
//
//swift_library(
// name = "BuildTestsLib",
// srcs = glob(["Tests/BuildTests/*.swift"]),
// deps = [":RepoToolsCore", "@podtobuild-SwiftCheck:SwiftCheck"],
// data = glob(["Examples*.podspec.json"])
//)
//
//# This tests RepoToolsCore and Starlark logic
//macos_unit_test(
// name = "BuildTests",
// deps = [":BuildTestsLib"],
// minimum_os_version = "10.13",
//)
