// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GandiDDNS",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "GandiDDNSLib", targets: ["GandiDDNSLib"]),
        .executable(name: "GandiDDNS", targets: ["GandiDDNS"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GandiDDNSLib"
        ),
        .target(
            name: "CommandLineParser"
        ),
        .executableTarget(
            name: "GandiDDNS",
            dependencies: [
                "GandiDDNSLib",
                "CommandLineParser"
            ]
        ),
        .testTarget(
            name: "GandiDDNSTests",
            dependencies: ["GandiDDNSLib"]),
        .testTarget(
            name: "CommandLineParserTests",
            dependencies: ["CommandLineParser"])
    ]
)
