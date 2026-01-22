// swift-tools-version: 5.9
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftOpenAPIGenerator open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftOpenAPIGenerator project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftOpenAPIGenerator project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import Foundation
import PackageDescription

// General Swift-settings for all targets.
var swiftSettings: [SwiftSetting] = [
    // https://github.com/apple/swift-evolution/blob/main/proposals/0335-existential-any.md
    // Require `any` for existential types.
    .enableUpcomingFeature("ExistentialAny")
]

// Strict concurrency is enabled in CI; use this environment variable to enable it locally.
if ProcessInfo.processInfo.environment["SWIFT_OPENAPI_STRICT_CONCURRENCY"].flatMap(Bool.init) ?? false {
    swiftSettings.append(contentsOf: [
        .define("SWIFT_OPENAPI_STRICT_CONCURRENCY"), .enableExperimentalFeature("StrictConcurrency"),
    ])
}

let package = Package(
    name: "candle-swift-openapi-urlsession",
    platforms: [.macOS(.v10_15), .macCatalyst(.v13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .visionOS(.v1)],
    products: [.library(name: "OpenAPIURLSession", targets: ["OpenAPIURLSession"])],
    dependencies: [
        .package(url: "https://github.com/candlefinance/swift-openapi-runtime", name: "candle-swift-openapi-runtime", branch: "fix-candle-1.8.2"),
        .package(url: "https://github.com/candlefinance/swift-http-types", name: "candle-swift-http-types", branch: "fix-candle-1.3.1"),
        .package(url: "https://github.com/candlefinance/swift-collections", name: "candle-swift-collections", branch: "fix-candle-1.1.4"),
    ],
    targets: [
        .target(
            name: "OpenAPIURLSession",
            dependencies: [
                .product(name: "CandleDequeModule", package: "candle-swift-collections"),
                .product(name: "CandleOpenAPIRuntime", package: "candle-swift-openapi-runtime"),
                .product(name: "CandleHTTPTypes", package: "candle-swift-http-types"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "OpenAPIURLSessionTests",
            dependencies: ["OpenAPIURLSession"],
            swiftSettings: swiftSettings
        ),
    ]
)

#if !os(Windows) // NIO not yet supported on Windows
// Test-only dependencies.
package.dependencies += [.package(url: "https://github.com/candlefinance/swift-nio", name: "candle-swift-nio", branch: "fix-candle-2.82.1")]
package.targets.forEach { target in
    if target.name == "OpenAPIURLSessionTests" {
        target.dependencies += [.product(name: "NIOTestUtils", package: "candle-swift-nio")]
    }
}
#endif

// ---    STANDARD CROSS-REPO SETTINGS DO NOT EDIT   --- //
for target in package.targets {
    switch target.type {
    case .regular, .test, .executable:
        var settings = target.swiftSettings ?? []
        // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
        settings.append(.enableUpcomingFeature("MemberImportVisibility"))
        target.swiftSettings = settings
    case .macro, .plugin, .system, .binary: ()  // not applicable
    @unknown default: ()  // we don't know what to do here, do nothing
    }
}
// --- END: STANDARD CROSS-REPO SETTINGS DO NOT EDIT --- //
