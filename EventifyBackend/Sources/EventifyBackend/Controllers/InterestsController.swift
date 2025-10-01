//
//  InterestsController.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 22/9/25.
//

import Vapor
import Fluent

//Creamos el controller para manejar las rutas relacionadas con los Interests.
struct InterestsController: RouteCollection, Sendable {
    func boot(routes: any RoutesBuilder) throws {
        let api = routes.grouped("interests")
        api.get(use: list)
        api.group(":interestID") { item in
            item.get(use: detail)
            item.patch(use: update)
            item.delete(use: delete)
        }
    }

    //Listamos todos los intereses ordenados por nombre ,orden ascendente.
    func list(_ req: Request) async throws -> [InterestDTO.Response] {
        let items = try await Interest.query(on: req.db)
            .sort(\.$name, .ascending)
            .all()
        return try items.map { try $0.toResponseDTO() }
    }

    // Creación de un interés nuevo.
    func create(_ req: Request) async throws -> InterestDTO.Response {
        try InterestDTO.Create.validate(content: req)
        let dto = try req.content.decode(InterestDTO.Create.self)
        let name = dto.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw Abort(.badRequest, reason: "Nombre vacío") }

        // Limpiar y asegurar unicidad por nameClean,evitamos conflictos.
        let clean = Interest.cleanName(from: name)
        let exists = try await Interest.query(on: req.db)
            .filter(\.$nameClean == clean)
            .first() != nil
        if exists { throw Abort(.badRequest, reason: "El interés ya existe") }

        let interest = Interest(name: name)
        interest.nameClean = clean
        try await interest.create(on: req.db)
        return try interest.toResponseDTO()
    }

    // Método útil para obtener el detalle de un interés por su respectivo ID.
    func detail(_ req: Request) async throws -> InterestDTO.Response {
        let interest = try await find(req)
        return try interest.toResponseDTO()
    }

    // Actualiza el nombre de un interés (si viene y no está vacío).
    func update(_ req: Request) async throws -> InterestDTO.Response {
        try InterestDTO.Update.validate(content: req)
        let dto = try req.content.decode(InterestDTO.Update.self)
        let interest = try await find(req)

        if let newName = dto.name?.trimmingCharacters(in: .whitespacesAndNewlines),
           !newName.isEmpty {
            interest.name = newName
            interest.nameClean = Interest.cleanName(from: newName)
            try await interest.save(on: req.db)
        }

        return try interest.toResponseDTO()
    }

    // Elimina un interés por su respectiva ID.
    func delete(_ req: Request) async throws -> HTTPStatus {
        let interest = try await find(req)
        try await interest.delete(on: req.db)
        return .noContent
    }

    // Busca un interés por `interestID` en la URL.
    private func find(_ req: Request) async throws -> Interest {
        guard let id = req.parameters.get("interestID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Falta interestID válido")
        }
        guard let i = try await Interest.find(id, on: req.db) else {
            throw Abort(.notFound, reason: "Interés no encontrado")
        }
        return i
    }
}
