import NIOSSL
import Fluent
import FluentSQLiteDriver
import FluentPostgresDriver
import QueuesRedisDriver
import Vapor
import JWT
import Foundation

public func configure(_ app: Application) async throws {
   
//Comprobación de que existe una JWT_KEY y API_KEY ,en caso contrario,no levanta servidor.
    guard let jwtKey = Environment.process.JWT_KEY else { fatalError("JWT_KEY not found") }
    guard let _ = Environment.process.API_KEY else { fatalError("API_KEY required") }

    
    switch app.environment {
    case .production:
        // Creación de PostgreSQL conexión ya que  la intención era levantar el servidor  con su respectivo dominio.
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
        // Configurar Redis conexion
        let redisHost = Environment.get("REDIS_HOST") ?? "redis"
        let redisPort = Environment.get("REDIS_PORT") ?? "6379"
        try app.queues.use(.redis(url: "redis://\(redisHost):\(redisPort)"))
        app.queues.add(EmailJob())
        try app.queues.startInProcessJobs(on: .email)
        
    default:
        app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    }
    
    // Guardar contraseña con algoritmo
    app.passwords.use(.bcrypt)
    
    // Configure JWT
    let hmacKey = HMACKey(stringLiteral: jwtKey)
    await app.jwt.keys.add(hmac: hmacKey, digestAlgorithm: .sha512)

    app.migrations.add(CreateUsers())
    app.migrations.add(CreateEvents())
    app.migrations.add(CreateInterests())
    app.migrations.add(CreateUserInterests())
    app.migrations.add(CreateEventAttendees())
    app.migrations.add(PopulateData())
    
    
    
    try await app.autoMigrate()

    // register routes
    try routes(app)
}
