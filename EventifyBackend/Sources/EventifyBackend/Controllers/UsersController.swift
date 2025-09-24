//
//  UsersController.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 9/9/25.
//

import Fluent
import Vapor

struct UsersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.get(":userID", use: show)
    }

    
    func index(req: Request) async throws -> [UsersDTO.Public] {
        let all = try await Users.query(on: req.db).all()
        return try all.map { try $0.toPublicDTO() }
    }

  
    func show(req: Request) async throws -> UsersDTO.Public {
        guard let user = try await Users.find(req.parameters.get("userID"), on: req.db)
        else { throw Abort(.notFound) }
        return try user.toPublicDTO()
    }
}
