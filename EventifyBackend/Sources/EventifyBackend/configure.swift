import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor


public func configure(_ app: Application) async throws {
  
    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateUsers())

    try routes(app)
}
