//
//  CreateInterests.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Fluent
import Vapor

//Migracion para crear la tabla de eventos.
//Cada fila representa la información de un evento por parte de  un usuario.
struct CreateEvents: AsyncMigration {
    func prepare(on database: any Database) async  throws {
        try await database.schema(ConstantsEvents.schemaEvents)
            .id()
            .field(ConstantsEvents.nameEvent, .string, .required)
            .field(ConstantsEvents.lat, .double)
            .field(ConstantsEvents.lng, .double)
            .field(ConstantsEvents.createdAt,.date)
            .field(ConstantsEvents.userID, .uuid, .required, .references(ConstantsUsers.schemaUsers, .id))
            .field(ConstantsEvents.updatedAt, .date)
            .field(ConstantsEvents.eventDate, .date)
            .field(ConstantsEvents.category, .string)
            .field(ConstantsEvents.location, .string)
            .create()
    }

    // Borra la tabla si hacemos rollback
    func revert(on database: any Database) async throws {
        try await database.schema(ConstantsEvents.schemaEvents).delete()
    }
}


