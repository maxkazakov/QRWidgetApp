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
            name: "QRGenerator",
            targets: ["QRGenerator"]
        ),
        .library(
            name: "CodeCreation",
            targets: ["CodeCreation"]
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
        .package(url: "https://github.com/sanzaru/SimpleToast.git", .upToNextMajor(from: "0.6.2")),
        .package(url: "https://github.com/efremidze/Haptica", .upToNextMajor(from: "3.0.3")),
        .package(url: "https://github.com/airbnb/lottie-ios", branch: "master"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.4.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.5.1")

    ],
    targets: [
        .target(
            name: "QRWidgetApp",
            dependencies: [
                "QRGenerator",
                "QRWidgetCore",
                "QRCodeUI",
                "CodeCreation",
                .product(name: "SimpleToast", package: "SimpleToast"),
                .product(name: "Haptica", package: "Haptica"),
                .product(name: "Lottie", package: "lottie-ios"),
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
            name: "QRGenerator",
            dependencies: ["QRWidgetCore"]
        ),
        .target(
            name: "QRCodeUI",
            dependencies: ["QRWidgetCore", "QRGenerator"],
            exclude: ["swiftgen.yml"]
        ),
        .target(
            name: "CodeCreation",
            dependencies: [
                "QRWidgetCore",
                "QRCodeUI",
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
            ],
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
