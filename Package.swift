// swift-tools-version: 6.1.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UnityFramework",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "UnityFramework",
            targets: ["UnityFramework", "UnityFrameworkLibrary"]
        ),
    ],
    targets: [
        .binaryTarget(name: "UnityFramework",
                      path: "./Frameworks/UnityFramework.zip"),
        .target(name: "UnityFrameworkLibrary",
                dependencies: ["UnityFramework"])

    ]
)
