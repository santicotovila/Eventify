

import Fluent
import Vapor

// Controlador de rutas para gestionar eventos.

struct EventsController: RouteCollection, Sendable {
    // Registramos las rutas del controlador bajo el prefijo /events.
    func boot(routes: any RoutesBuilder) throws {
        let events = routes.grouped("events")
        events.get(use: list)
        events.post(use: create)
        events.group(":eventID") { e in
            e.get(use: detail)
            e.patch(use: update)
            e.delete(use: delete)
        }
    }

    // Lista paginada de eventos, ordenados por fecha de creación descendente.
    func list(_ req: Request) async throws -> Page<EventsDTO.Public> {
        let page = try await Events.query(on: req.db)
            .sort(\.$createdAt, .descending)  // Orden por fecha de creación descendente
            .paginate(for: req)               // Paginación automática a partir del query string
        return try page.map { try $0.toPublicDTO() }
    }

    // Obtenemos el detalle de un evento por su `eventID` en la URL.
    func detail(_ req: Request) async throws -> EventsDTO.Public {
        let event = try await find(req)
        return try event.toPublicDTO()
    }

  //Método que nos permite crear un evento.
    func create(_ req: Request) async throws -> EventsDTO.Public {
        try EventsDTO.Create.validate(content: req)           // Validación de payload
        let dto = try req.content.decode(EventsDTO.Create.self)
        
        //TODO: - Pendiente de implementar cuando trabajemos ya con los lugares cercanos
/*
        //ütiles para la ubicacion de los locales cercanos al usuario los cuales le  interesa
        if (dto.lat == nil) != (dto.lng == nil) {
            throw Abort(.badRequest, reason: "lat y lng deben venir juntos")
        }*/

        let model = dto.toModel()
        try await model.create(on: req.db)
        return try model.toPublicDTO()
    }

    // Actualiza  un evento existente.
    func update(_ req: Request) async throws -> EventsDTO.Public {
        try EventsDTO.Update.validate(content: req)           // Validación de payload
        let dto = try req.content.decode(EventsDTO.Update.self)
        let event = try await find(req)                       // Buscar evento

        // Actualiza 'name' si no viene vacío
        if let name = dto.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            event.name = name
        }
        // Actualizamos category si no viene vacía
        if let category = dto.category?.trimmingCharacters(in: .whitespacesAndNewlines), !category.isEmpty {
            event.category = category
        }
        
        
        //TODO: - Pendiente de implementar cuando trabajemos ya con los lugares cercanos
      /*  if (dto.lat == nil) != (dto.lng == nil) {
            throw Abort(.badRequest, reason: "lat y lng deben venir juntos")
        }
        // Actualizamos coordenadas si se proporcionan
        if let lat = dto.lat { event.lat = lat }
        if let lng = dto.lng { event.lng = lng }*/
      
        try await event.save(on: req.db)
        return try event.toPublicDTO()
    }

    // Busca un evento por `eventID` en la URL.
    private func find(_ req: Request) async throws -> Events {
        guard let id = req.parameters.get("eventID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Falta eventID válido")
        }
        guard let event = try await Events.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Evento no encontrado")
        }
        return event
    }
    
    // Elimina un evento por su respectiva ID
    func delete(_ req: Request) async throws -> HTTPStatus {
        let event = try await find(req)
        try await event.delete(on: req.db)
        return .noContent }

}
