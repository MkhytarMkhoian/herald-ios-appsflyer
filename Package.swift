// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "herald-ios-appsflyer",
    // macOS is listed so the tests can run with `swift test` on a Mac.
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(name: "HeraldAppsFlyer", targets: ["HeraldAppsFlyer"])
    ],
    dependencies: [
        .package(url: "https://github.com/MkhytarMkhoian/herald-ios", from: "1.0.0"),
        .package(url: "https://github.com/AppsFlyerSDK/AppsFlyerFramework", from: "7.0.0"),
    ],
    targets: [
        .target(
            name: "HeraldAppsFlyer",
            dependencies: [
                .product(name: "HeraldCore", package: "herald-ios"),
                .product(name: "AppsFlyerLib", package: "AppsFlyerFramework"),
            ]
        ),
        .testTarget(
            name: "HeraldAppsFlyerTests",
            dependencies: [
                "HeraldAppsFlyer",
                .product(name: "HeraldTesting", package: "herald-ios"),
            ]
        ),
    ]
)
