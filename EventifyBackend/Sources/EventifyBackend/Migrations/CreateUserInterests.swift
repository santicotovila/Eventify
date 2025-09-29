//
//  CreateUserInterests.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Fluent
import Vapor


import Fluent

//Migracion para crear la tabla de intereses de cada usuario,lo cual se lleva a cabo en el registro.
//Cada fila representa información de los intereses del usuario.
struct CreateUserInterests: AsyncMigration {
    func prepare(on db: any Database) async throws {
        try await db.schema(ConstantsUserInterests.schemaUserInterests)
            .id()
            .field(ConstantsUserInterests.userID, .uuid, .required,
                   .references(ConstantsUsers.schemaUsers, .id, onDelete: .cascade))
            .field(ConstantsUserInterests.interestID, .uuid, .required,
                   .references(ConstantsInterests.schemaInterests, .id, onDelete: .cascade))
            .unique(on: ConstantsUserInterests.userID, ConstantsUserInterests.interestID)
            .create()
    }

    func revert(on db: any Database) async throws {
        try await db.schema(ConstantsUserInterests.schemaUserInterests).delete()
    }
}
