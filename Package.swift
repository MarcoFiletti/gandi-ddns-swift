// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GandiDDNS",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "GandiDDNSLib"),
        .target(name: "CommandLineParser"),
        .target(
            name: "GandiDDNS",
            dependencies: ["GandiDDNSLib", "CommandLineParser"]),
        .testTarget(
            name: "GandiDDNSTests",
            dependencies: ["GandiDDNSLib"]),
        .testTarget(
            name: "CommandLineParserTests",
            dependencies: ["CommandLineParser"])
    ]
)
