// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XMLTextRenderKit",
    platforms: [ .iOS(.v15) ],
    products: [
        .library(name: "XMLTextRenderKit", targets: ["XMLTextRenderKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "XMLTextRenderKit",
            dependencies: [
                .product(name: "SWXMLHash", package: "SWXMLHash"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
