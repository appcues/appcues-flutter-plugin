// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "appcues_flutter",
    platforms: [
        .iOS("11.0"),
    ],
    products: [
        .library(name: "appcues-flutter", targets: ["appcues_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/appcues/appcues-ios-sdk", from: "4.3.9"),
    ],
    targets: [
        .target(
            name: "appcues_flutter",
            dependencies: [
                .product(name: "AppcuesKit", package: "appcues-ios-sdk"),
            ],
            resources: []
        )
    ]
)
