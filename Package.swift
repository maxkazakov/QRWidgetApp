// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRWidgetApp",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .watchOS(.v7)],

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
            name: "CodeImageGenerator",
            targets: ["CodeImageGenerator"]
        ),
        .library(
            name: "QRCodeUI",
            targets: ["QRCodeUI"]
        ),
        .library(
            name: "QRWatch",
            targets: ["QRWatch"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sanzaru/SimpleToast.git", .upToNextMajor(from: "0.7.2")),
        .package(url: "https://github.com/efremidze/Haptica", .upToNextMajor(from: "3.0.3")),
        .package(url: "https://github.com/airbnb/lottie-ios", branch: "master"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.4.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.5.1"),
        .package(url: "https://github.com/dagronf/qrcode.git", from: "15.1.0")

    ],
    targets: [
        .target(
            name: "QRWidgetApp",
            dependencies: [
                "CodeImageGenerator",
                "QRWidgetCore",
                "QRCodeUI",
                .product(name: "SimpleToast", package: "SimpleToast"),
                .product(name: "Haptica", package: "Haptica"),
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            exclude: ["swiftgen.yml"],
            resources: [.process("Resources/LottieAnimations")]
        ),
        .target(
            name: "QRWidgetCore",
            dependencies: [],
            exclude: ["swiftgen.yml"]
        ),
        .target(
            name: "CodeImageGenerator",
            dependencies: [
                "QRWidgetCore",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "QRCode", package: "qrcode"),
            ]
        ),
        .target(
            name: "QRCodeUI",
            dependencies: ["QRWidgetCore", "CodeImageGenerator"],
            exclude: ["swiftgen.yml"]
        ),
        .target(
            name: "QRWatch",
            dependencies: ["QRWidgetCore"]
        ),

        .testTarget(
            name: "QRWidgetAppTests",
            dependencies: ["QRWidgetApp"]
        ),
    ]
)
