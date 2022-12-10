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
            url: "https://github.com/codeface-io/LSPServiceKit.git",
            exact: "0.2.0"
        ),
        .package(
            url: "https://github.com/codeface-io/SwiftLSP.git",
            exact: "0.3.4"
        ),
        .package(
            url: "https://github.com/flowtoolz/FoundationToolz.git",
            exact: "0.1.3"
        ),
        .package(
            url: "https://github.com/codeface-io/SwiftNodes.git",
            exact: "0.3.3"
        ),
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            exact: "0.2.0"
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
                "SwiftNodes",
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
