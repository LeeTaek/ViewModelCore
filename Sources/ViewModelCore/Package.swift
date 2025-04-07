// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewModelCore",
    products: [
        .library(name: "ViewModelCore", targets: ["ViewModelCore"])
    ],
    dependencies: [
        .package(path: "../BindingSupport"),
        .package(path: "../Macro")
    ],
    targets: [
        .target(
            name: "ViewModelCore",
            dependencies: [
                .product(name: "BindingSupport", package: "BindingSupport"),
                .product(name: "ViewModelMacro", package: "Macro")
            ]
        )
    ]
)
