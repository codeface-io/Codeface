// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CodefaceCore",
    platforms: [.iOS(.v12), .tvOS(.v12), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CodefaceCore",
            targets: ["CodefaceCore"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/flowtoolz/LSPServiceKit.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/flowtoolz/SwiftLSP.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/flowtoolz/FoundationToolz.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.2"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CodefaceCore",
            dependencies: [
                "SwiftLSP",
                "FoundationToolz",
                "SwiftyToolz",
                .product(name: "OrderedCollections",
                         package: "swift-collections"),
                "LSPServiceKit"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CodefaceCoreTests",
            dependencies: ["CodefaceCore"],
            path: "Tests"
        ),
    ]
)
