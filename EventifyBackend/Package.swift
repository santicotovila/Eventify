// swift-tools-version:6.0
// Package manifest for the Eventify backend. This file declares supported platforms,
// external dependencies, products, and targets used to build and test the app.

import PackageDescription

let package = Package(
    name: "EventifyBackend",
    // The minimum platform the package supports. macOS 13 aligns with modern Swift 6 and Vapor 4 support.
    platforms: [
       .macOS(.v13)
    ],
    products: [
        // The server runs as a command-line executable.
        .executable(name: "EventifyBackend", targets: ["EventifyBackend"])
    ],
    dependencies: [
        // 💧 Vapor: the web framework providing HTTP server, routing, middleware, etc.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🗄 Fluent: ORM abstraction used by models, migrations, and query builders.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🪶 Fluent SQLite driver: useful for local development or lightweight deployments.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
        // 🪶 Fluent Postgres driver: preferred for production environments.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        // 🔵 SwiftNIO: low-level event-driven networking. Imported explicitly for custom executors/event loops if needed.
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🔵 JWT: token signing and verification for authentication flows.
        .package(url: "https://github.com/vapor/jwt.git", from: "5.1.0"),
        // 🔵 Redis-backed job queues for background work (e.g., sending emails).
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "EventifyBackend",
            dependencies: [
                // Core ORM and database drivers.
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                // Web framework.
                .product(name: "Vapor", package: "vapor"),
                // Explicit NIO products in case the app uses EventLoopGroup/Posix bootstrap directly.
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                // JWT auth support.
                .product(name: "JWT", package: "jwt"),
                // Redis queues driver to run AsyncJob tasks.
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver")
            ],
            // Keep Swift settings centralized so tests and executable share the same compiler flags.
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "EventifyBackendTests",
            dependencies: [
                .target(name: "EventifyBackend"),
                // VaporTesting provides helpers for request/response assertions against Application.
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

// Centralized Swift compiler settings.
// Note: ExistentialAny enforces explicit use of 'any' for existential types, matching Swift 6 behavior.
// Keeping it explicit helps with clarity and forward compatibility across toolchains.
var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
