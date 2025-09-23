//
//  CreateInterests.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Fluent
import Vapor

struct CreateEvents: AsyncMigration {
    func prepare(on database: any Database) async  throws {
        try await database.schema(ConstantsEvents.schemaEvents)
            .id()
            .field(ConstantsEvents.nameEvent, .string, .required)
            .field(ConstantsEvents.lat, .double)
            .field(ConstantsEvents.lng, .double)
            .field(ConstantsEvents.createdAt,.date)
            .field(ConstantsEvents.userID, .uuid, .required, .references(ConstantsUsers.schemaUsers, .id))
            .field(ConstantsEvents.updatedAt,.date)
            .field(ConstantsEvents.category, .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(ConstantsEvents.schemaEvents).delete()
    }
}


