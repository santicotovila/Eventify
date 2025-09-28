//
//  UsersController.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 9/9/25.
//

import Fluent
import Vapor
//Creamos el controller para manejar las  rutas relacionas con Users
struct UsersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)

        users.group(":userID") { u in
            u.get(use: show)
            u.delete(use: delete)
        }
    }

    //Obtenemos todos los usuarios.
    func index(req: Request) async throws -> [UsersDTO.Public] {
        let all = try await Users.query(on: req.db).all()
        return try all.map { try $0.toPublicDTO() }
    }

  // Devolvemos el usuario aue nos interesa por su respectiva ID
    func show(req: Request) async throws -> UsersDTO.Public {
        guard let user = try await Users.find(req.parameters.get("userID"), on: req.db)
        else { throw Abort(.notFound) }
        return try user.toPublicDTO()
    }
    
    
    //Borramos el usuario que nos interesa por ID
    func delete(_ req: Request) async throws -> HTTPStatus {
        guard let user = try await Users.find(req.parameters.get("userID"), on: req.db)
        else { throw Abort(.notFound)}
         try await user.delete(on: req.db)
         return .noContent
     }
    
}
