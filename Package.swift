// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRWidgetApp",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],

    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "QRWidgetApp",
            targets: ["QRWidgetApp"]
        ),
        .library(
            name: "QRWidgetCore",
            targets: ["QRWidgetCore"]
        ),
        .library(
            name: "QRGenerator",
            targets: ["QRGenerator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sanzaru/SimpleToast.git", .upToNextMajor(from: "0.6.2")),
        .package(url: "https://github.com/efremidze/Haptica", .upToNextMajor(from: "3.0.3")),
        .package(url: "https://github.com/airbnb/lottie-ios", branch: "master"),
    ],
    targets: [
        .target(
            name: "QRWidgetApp",
            dependencies: [
                "QRGenerator",
                "QRWidgetCore",
                .product(name: "SimpleToast", package: "SimpleToast"),
                .product(name: "Haptica", package: "Haptica"),
                .product(name: "Lottie", package: "lottie-ios"),
            ],
            exclude: ["swiftgen.yml", "crowdin.yml"],
            resources: [.process("Resources/LottieAnimations")]
        ),
        .target(
            name: "QRWidgetCore",
            dependencies: []
        ),
        .target(
            name: "QRGenerator",
            dependencies: ["QRWidgetCore"]
        ),
        .testTarget(
            name: "QRWidgetAppTests",
            dependencies: ["QRWidgetApp"]
        ),
    ]
)
