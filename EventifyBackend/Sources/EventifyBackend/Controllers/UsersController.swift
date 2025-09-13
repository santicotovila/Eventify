//
//  UsersController.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 9/9/25.
//

import Fluent
import Vapor

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("api", "users")
        users.get(use: index)                  // GET /api/users
        users.get(":userID", use: show)        // GET /api/users/:userID
    }

    // GET /api/users
    func index(req: Request) async throws -> [Users.Public] {
        let all = try await Users.query(on: req.db).all()
        return all.map { $0.toPublic() }
    }

    // GET /api/users/:userID
    func show(req: Request) async throws -> Users.Public {
        guard let user = try await Users.find(req.parameters.get("userID"), on: req.db)
        else { throw Abort(.notFound) }
        return user.toPublic()
    }
}
