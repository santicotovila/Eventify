import NIOSSL
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import QueuesRedisDriver
import Vapor
import JWT
import Foundation


#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

// Minimal .env loader to avoid external DotEnv dependency.
private func loadDotEnv(from path: String, overrideExisting: Bool = false) {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else { return }
    guard let contents = try? String(contentsOf: url, encoding: .utf8) else { return }
    
    for rawLine in contents.split(whereSeparator: \.isNewline) {
        var line = String(rawLine).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !line.isEmpty, !line.hasPrefix("#") else { continue }
        
        if line.hasPrefix("export ") { line = String(line.dropFirst(7)) }
        guard let eq = line.firstIndex(of: "=") else { continue }
        
        let key = String(line[..<eq]).trimmingCharacters(in: .whitespacesAndNewlines)
        var value = String(line[line.index(after: eq)...]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        if value.hasPrefix("\""), value.hasSuffix("\""), value.count >= 2 {
            value = String(value.dropFirst().dropLast())
        } else if value.hasPrefix("'"), value.hasSuffix("'"), value.count >= 2 {
            value = String(value.dropFirst().dropLast())
        } else if let hashIndex = value.firstIndex(of: "#") {
            // Strip inline comments for unquoted values: KEY=value # comment
            value = String(value[..<hashIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if !overrideExisting, getenv(key) != nil { continue }
        setenv(key, value, 1)
    }
}

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    // Load environment files if present (no external dependency needed).
    loadDotEnv(from: app.directory.workingDirectory + ".env.local")
    loadDotEnv(from: app.directory.workingDirectory + ".env")
    
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
    app.migrations.add(CreateEventAttendees())
    
    
    // En production deberíamos quitarlo
    try await app.autoMigrate()

    // register routes
    try routes(app)
}
