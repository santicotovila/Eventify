//
//  CreateInterests.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Vapor
import Fluent

struct CreateInterests: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(ConstantsInterests.schemaInterests)
            .id()
            .field(ConstantsInterests.name, .string, .required)
            .field(ConstantsInterests.nameClean, .string, .required)
            .unique(on: ConstantsInterests.nameClean)
            .create()
    }
    
    func revert(on db: any Database) async throws {
        try await db.schema(ConstantsInterests.schemaInterests).delete()
    }
}
