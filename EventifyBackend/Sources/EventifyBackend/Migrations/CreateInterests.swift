

import Vapor
import Fluent


//Migracion para crear intereses nuevos.

struct CreateInterests: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(ConstantsInterests.schemaInterests)
            .id()
            .field(ConstantsInterests.name, .string, .required)
            .field(ConstantsInterests.nameClean, .string, .required)
            .unique(on: ConstantsInterests.nameClean)
            .create()
    }
    
    // Borra la tabla si hacemos rollback
    func revert(on db: any Database) async throws {
        try await db.schema(ConstantsInterests.schemaInterests).delete()
    }
}
