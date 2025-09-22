// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "EventifyBackend",
    platforms: [
       .macOS(.v13)
    ],
    products: [
        // Producto ejecutable para que Xcode cree un esquema "runnable"
        .executable(name: "EventifyBackend", targets: ["EventifyBackend"])
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🪶 Fluent driver for SQLite.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
        // 🪶 Fluent driver for PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🔵 JWT Authentication
        .package(url: "https://github.com/vapor/jwt.git", from: "5.1.0"),
        // 🔵 Redis Queues Driver
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "EventifyBackend",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "EventifyBackendTests",
            dependencies: [
                .target(name: "EventifyBackend"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
