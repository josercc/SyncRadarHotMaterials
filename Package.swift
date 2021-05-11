// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SyncRadarHotMaterials",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
//        .library(
//            name: "SyncRadarHotMaterials",
//            targets: ["SyncRadarHotMaterials"])
        .executable(name: "syncRHM", targets: ["SyncRadarHotMaterials"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://gitee.com/joser_zhang/swift-argument-parser.git", from: "0.4.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(name: "SyncRadarHotMaterials", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "Alamofire",
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(
            name: "SyncRadarHotMaterialsTests",
            dependencies: ["SyncRadarHotMaterials"]),
    ]
)
