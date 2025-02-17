// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftui-customizable-tab-view",
    products: [
        .library(name: "CustomizableTabView", targets: ["CustomizableTabView"]),
    ],
    targets: [
        .target(name: "CustomizableTabView"),
        .testTarget(
            name: "CustomizableTabViewTests",
            dependencies: ["CustomizableTabView"]
          ),
    ]
)
