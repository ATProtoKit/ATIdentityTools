// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ATIdentityTools",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .tvOS(.v14),
        .visionOS(.v1),
        .watchOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ATIdentityTools",
            targets: ["ATIdentityTools"]),
        .library(
            name: "DIDCore",
            targets: ["DIDCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/ATProtoKit/ATCommonTools.git", .upToNextMajor(from: "0.0.1")),
        .package(url: "https://github.com/ATProtoKit/ATCryptography.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-async-dns-resolver", .upToNextMajor(from: "0.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ATIdentityTools",
            dependencies: [
                .product(name: "ATCommonTools", package: "atcommontools"),
                .product(name: "ATCommonWeb", package: "atcommontools"),
                .product(name: "ATCryptography", package: "atcryptography"),
                .product(name: "AsyncDNSResolver", package: "swift-async-dns-resolver")
            ]
        ),
        .target(
            name: "DIDCore"),
        .testTarget(
            name: "ATIdentityToolsTests",
            dependencies: ["ATIdentityTools", "DIDCore"]
        ),
    ]
)

let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
    .enableUpcomingFeature("InferSendableFromCaptures"),
]

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(contentsOf: swiftSettings)
    target.swiftSettings = settings
}
