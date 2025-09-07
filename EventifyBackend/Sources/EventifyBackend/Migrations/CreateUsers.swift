import Fluent
import Vapor

struct CreateUsers: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(ConstantsUsers.schemaUsers)
            .id()
            .field(ConstantsUsers.name, .string, .required)
            .field(ConstantsUsers.email, .string, .required)
            .field(ConstantsUsers.password,.string, .required)
            .field(ConstantsUsers.isAdmin, .bool, .required)
            .field(ConstantsUsers.createdAt,.date)
            .field(ConstantsUsers.updatedAt,.date)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(ConstantsUsers.schemaUsers).delete()
    }
}
