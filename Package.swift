// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftui-customizable-tab-view",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "CustomizableTabView", targets: ["CustomizableTabView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "CustomizableTabView",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .testTarget(
            name: "CustomizableTabViewTests",
            dependencies: ["CustomizableTabView"]
          ),
    ]
)
