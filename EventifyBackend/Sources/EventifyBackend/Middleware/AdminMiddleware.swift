//
//  AdminMiddleware.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 23/9/25.
//

import Vapor

struct AdminMiddleware: AsyncMiddleware {
    
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        let token = try request.auth.require(JWTToken.self)
        
        guard let userId = UUID(token.userID.value),
              let user = try await Users.find(userId, on: request.db),
              user.isAdmin else {
            throw Abort(.unauthorized)
        }
        return try await next.respond(to: request)
    }
}
