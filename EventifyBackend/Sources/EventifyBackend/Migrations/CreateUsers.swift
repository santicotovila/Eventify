import Fluent
import Vapor


//Migracion para crear la tabla de usuarios.
//Cada fila representa información de cada usuario.
struct CreateUsers: AsyncMigration {
    func prepare(on database: any Database) async  throws {
        try await database.schema(ConstantsUsers.schemaUsers)
            .id()
            .field(ConstantsUsers.name, .string, .required)
            .field(ConstantsUsers.email, .string, .required)
            .field(ConstantsUsers.password,.string, .required)
            .field(ConstantsUsers.interests,.array,.required)
            .field(ConstantsUsers.lat, .double)
            .field(ConstantsUsers.lng, .double)
            .field(ConstantsUsers.isAdmin, .bool, .required)
            .field(ConstantsUsers.createdAt,.date)
            .field(ConstantsUsers.updatedAt,.date)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(ConstantsUsers.schemaUsers).delete()
    }
}
