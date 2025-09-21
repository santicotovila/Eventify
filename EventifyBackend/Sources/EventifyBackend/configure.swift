import NIOSSL
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import QueuesRedisDriver
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    guard let jwtKey = Environment.process.JWT_KEY else { fatalError("JWT_KEY not found") }
    guard let _ = Environment.process.API_KEY else { fatalError("API_KEY required") }
    
    switch app.environment {
    case .production:
        // create PostgreSQL connection
        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                    port: 5432,
                    username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
                    password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
                    database: Environment.get("DATABASE_DATABASE") ?? "vapor_database",
                    tls: .disable
                )
            ),
            as: .psql
        )
        // Configure Redis connection
        let redisHost = Environment.get("REDIS_HOST") ?? "redis"
        let redisPort = Environment.get("REDIS_PORT") ?? "6379"
        try app.queues.use(.redis(url: "redis://\(redisHost):\(redisPort)"))
        app.queues.add(EmailJob())
        try app.queues.startInProcessJobs(on: .email)
        
    default:
        app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
    // Set password algorithm
    app.passwords.use(.bcrypt)
    
    // Configure JWT
    let hmacKey = HMACKey(stringLiteral: jwtKey)
    await app.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha512)

    app.migrations.add(CreateUsers())
    app.migrations.add(CreateEvents())
    app.migrations.add(CreateInterests())
    app.migrations.add(CreateUserInterests())
    
    
    // En production deberíamos quitarlo
    try await app.autoMigrate()

    // register routes
    try routes(app)
}
