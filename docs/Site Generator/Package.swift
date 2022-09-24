// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SiteGenerator",
    platforms: [.iOS(.v11), .tvOS(.v11), .macOS(.v10_14)],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            url: "https://github.com/flowtoolz/FoundationToolz.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/flowtoolz/SwiftyToolz.git",
            branch: "master"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "SiteGenerator",
            dependencies: ["FoundationToolz", "SwiftyToolz"],
            path: "Code"
        )
    ]
)
