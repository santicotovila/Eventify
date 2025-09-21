//
//  CreateEventAttendees.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 22/9/25.
//

import Vapor
import Fluent

struct CreateEventAttendees: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(ConstantsEventAttendees.schema)
            .id()
            .field(ConstantsEventAttendees.eventID, .uuid, .required,
                   .references(ConstantsEvents.schemaEvents, .id, onDelete: .cascade))
            .field(ConstantsEventAttendees.userID, .uuid, .required,
                   .references(ConstantsUsers.schemaUsers, .id, onDelete: .cascade))
            .field(ConstantsEventAttendees.status, .string, .required)
            .field(ConstantsEventAttendees.joinedAt, .datetime)
            .field(ConstantsEventAttendees.updatedAt, .datetime)
            .unique(on: ConstantsEventAttendees.eventID, ConstantsEventAttendees.userID) // 1 por usuario/evento
            .create()
    }

    func revert(on db: any Database) async throws {
        try await db.schema(ConstantsEventAttendees.schema).delete()
    }
}
