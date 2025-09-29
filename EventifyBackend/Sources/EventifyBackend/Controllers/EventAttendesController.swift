//
//  EventAttendesController.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 22/9/25.
//

import Vapor
import Fluent

// Controlador de rutas para gestionar las asistencias a eventos.
struct EventAttendeesController: RouteCollection, Sendable {

    // Registra las rutas del controlador.
  
    func boot(routes: any RoutesBuilder) throws {
        let rsvp = routes.grouped("rsvp")

        rsvp.post(use: createWithUserID)
        routes.grouped(JWTUserAuthenticator(), Users.guardMiddleware())
            .group(":eventID") { e in
                e.post("rsvp", use: createFromJWT)
            }
    }

    func createWithUserID(_ req: Request) async throws -> EventAttendeesDTO.Public {
        try EventAttendeesDTO.Create.validate(content: req)
        let dto = try req.content.decode(EventAttendeesDTO.Create.self)

        // Comprobar existencia de event y users
        guard try await Events.find(dto.eventID, on: req.db) != nil
        else { throw Abort(.notFound, reason: "Evento no existe") }
        guard try await Users.find(dto.userID, on: req.db) != nil
        else { throw Abort(.notFound, reason: "Usuario no existe") }

        // Unicidad por (event y user). Si existe, actualizamos si no, creamos.
        if let existing = try await EventAttendee.query(on: req.db)
            .filter(\.$event.$id == dto.eventID)
            .filter(\.$user.$id == dto.userID)
            .first()
        {
            existing.status = dto.status.rawValue
            try await existing.save(on: req.db)
            return try existing.toPublicDTO()
        }

        let record = EventAttendee(eventID: dto.eventID, userID: dto.userID, status: dto.status)
        try await record.create(on: req.db)
        return try record.toPublicDTO()
    }

    func createFromJWT(_ req: Request) async throws -> EventAttendeesDTO.Public {
        try EventAttendeesDTO.CreateFromJWT.validate(content: req)
        let dto = try req.content.decode(EventAttendeesDTO.CreateFromJWT.self)
        let user = try req.auth.require(Users.self)
        let userID = try user.requireID()

        if let urlID = req.parameters.get("eventID", as: UUID.self), urlID != dto.eventID {
            throw Abort(.badRequest, reason: "eventID URL != body")
        }

        let record = EventAttendee(eventID: dto.eventID, userID: userID, status: dto.status)
        try await record.create(on: req.db)
        return try record.toPublicDTO()
    }

    // Actualiza el estado de un rsvp existente para el usuario autenticado y el eventID.
    func updateFromJWT(_ req: Request) async throws -> EventAttendeesDTO.Public {
        let user = try req.auth.require(Users.self)
        let userID = try user.requireID()
        let dto = try req.content.decode(EventAttendeesDTO.Update.self)

        guard let eventID = req.parameters.get("eventID", as: UUID.self)
        else { throw Abort(.badRequest, reason: "Falta eventID en URL") }

        guard let existing = try await EventAttendee.query(on: req.db)
            .filter(\.$event.$id == eventID)
            .filter(\.$user.$id == userID)
            .first()
        else {
            throw Abort(.notFound, reason: "No tenías RSVP para este evento")
        }

        existing.status = dto.status.rawValue
        try await existing.save(on: req.db)
        return try existing.toPublicDTO()
    }
    
    // Eliminamos el RSVP del usuario
    func deleteFromJWT(_ req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(Users.self)
        let userID = try user.requireID()

        guard let eventID = req.parameters.get("eventID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Falta eventID en URL")
        }

        guard let existing = try await EventAttendee.query(on: req.db)
            .filter(\.$event.$id == eventID)
            .filter(\.$user.$id == userID)
            .first()
        else {
            throw Abort(.notFound, reason: "No tenías RSVP para este evento")
        }

        try await existing.delete(on: req.db)
        return .noContent
    }

}

// MARK: - Mapper a DTO
extension EventAttendee {
    // Convierte el modelo EventAttendee a su representación pública EventAttendeesDTO.Public
    func toPublicDTO() throws -> EventAttendeesDTO.Public {
        guard let id = self.id else {
            throw Abort(.internalServerError, reason: "EventAttendee sin ID")
        }
        guard let statusEnum = EventStatus(rawValue: self.status) else {
            throw Abort(.internalServerError, reason: "Estado inválido: \(self.status)")
        }
        return .init(
            id: id,
            eventID: self.$event.id,
            userID: self.$user.id,
            status: statusEnum,
            joinedAt: self.joinedAt,
            updatedAt: self.updatedAt
        )
    }
}
