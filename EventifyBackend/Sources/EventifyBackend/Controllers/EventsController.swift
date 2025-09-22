//
//  EventsController.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 22/9/25.
//

import Fluent
import Vapor


struct EventsController: RouteCollection, Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let events = routes.grouped("events")
        events.get(use: list)
        events.post(use: create) // puedes proteger con auth si quieres
        events.group(":eventID") { e in
            e.get(use: detail)
            e.patch(use: update)
        }
    }

    func list(_ req: Request) async throws -> Page<EventsDTO.Public> {
        let page = try await Events.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .paginate(for: req)
        return try page.map { try $0.toPublicDTO() }
    }

    func detail(_ req: Request) async throws -> EventsDTO.Public {
        let event = try await find(req)
        return try event.toPublicDTO()
    }

    func create(_ req: Request) async throws -> EventsDTO.Public {
        try EventsDTO.Create.validate(content: req)
        let dto = try req.content.decode(EventsDTO.Create.self)

        // Coherencia lat/lng juntos
        if (dto.lat == nil) != (dto.lng == nil) {
            throw Abort(.badRequest, reason: "lat y lng deben venir juntos")
        }

        let model = dto.toModel()
        try await model.create(on: req.db)
        return try model.toPublicDTO()
    }

    struct EventUpdateDTO: Content, Validatable {
        let name: String?
        let category: String?
        let lat: Double?
        let lng: Double?

        static func validations(_ v: inout Validations) {
            v.add("name", as: String?.self, is: .nil || .count(1...))
            v.add("category", as: String?.self, is: .nil || .count(1...))
            v.add("lat", as: Double?.self, is: .nil || .range(-90...90))
            v.add("lng", as: Double?.self, is: .nil || .range(-180...180))
        }
    }

    func update(_ req: Request) async throws -> EventsDTO.Public {
        try EventUpdateDTO.validate(content: req)
        let dto = try req.content.decode(EventUpdateDTO.self)
        let event = try await find(req)

        if let name = dto.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            event.name = name
        }
        if let category = dto.category?.trimmingCharacters(in: .whitespacesAndNewlines), !category.isEmpty {
            event.category = category
        }
        if (dto.lat == nil) != (dto.lng == nil) {
            throw Abort(.badRequest, reason: "lat y lng deben venir juntos")
        }
        if let lat = dto.lat { event.lat = lat }
        if let lng = dto.lng { event.lng = lng }

        try await event.save(on: req.db)
        return try event.toPublicDTO()
    }

    private func find(_ req: Request) async throws -> Events {
        guard let id = req.parameters.get("eventID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Falta eventID válido")
        }
        guard let event = try await Events.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Evento no encontrado")
        }
        return event
    }
}

