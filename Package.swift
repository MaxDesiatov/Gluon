// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
  ],
  products: [
    // Products define the executables and libraries produced by a package,
    // and make them visible to other packages.
    .executable(
      name: "TokamakDemo",
      targets: ["TokamakDemo"]
    ),
    .library(
      name: "TokamakDOM",
      targets: ["TokamakDOM"]
    ),
    .library(
      name: "TokamakShim",
      targets: ["TokamakShim"]
    ),
    .library(
      name: "TokamakStaticHTML",
      targets: ["TokamakStaticHTML"]
    ),
    .executable(
      name: "TokamakStaticDemo",
      targets: ["TokamakStaticDemo"]
    ),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      .upToNextMinor(from: "0.7.2")
    ),
    .package(url: "https://github.com/MaxDesiatov/Runtime.git", from: "2.1.2"),
    .package(url: "https://github.com/MaxDesiatov/OpenCombine.git", from: "0.0.1"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define
    // a module or a test suite.
    // Targets can depend on other targets in this package, and on products
    // in packages which this package depends on.
    .target(
      name: "CombineShim",
      dependencies: [.product(
        name: "OpenCombine",
        package: "OpenCombine",
        condition: .when(platforms: [.wasi, .linux])
      )]
    ),
    .target(
      name: "TokamakCore",
      dependencies: ["CombineShim", "Runtime"]
    ),
    .target(
      name: "TokamakStaticHTML",
      dependencies: [
        "TokamakCore",
      ]
    ),
    .target(
      name: "TokamakDOM",
      dependencies: ["CombineShim", "JavaScriptKit", "TokamakCore", "TokamakStaticHTML"]
    ),
    .target(
      name: "TokamakShim",
      dependencies: [.target(name: "TokamakDOM", condition: .when(platforms: [.wasi]))]
    ),
    .target(
      name: "TokamakDemo",
      dependencies: ["JavaScriptKit", "TokamakShim"]
    ),
    .target(
      name: "TokamakStaticDemo",
      dependencies: [
        "TokamakStaticHTML",
      ]
    ),
    .target(
      name: "TokamakTestRenderer",
      dependencies: ["TokamakCore"]
    ),
    .testTarget(
      name: "TokamakTests",
      dependencies: ["TokamakDemo", "TokamakTestRenderer"]
    ),
  ]
)
