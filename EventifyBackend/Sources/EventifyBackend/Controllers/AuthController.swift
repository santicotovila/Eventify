import Fluent
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.group("auth") { builder in
            builder.post("register", use: register)
            builder.group(Users.authenticator(),Users.guardMiddleware()) { builder in
                builder.post("login",use: login)
            }
        }
    }
}

extension AuthController {
    func register(req: Request) async throws -> HTTPStatus {
        
        //Validate data
        try UsersDTO.Create.validate(content: req)
        
        //Decode
        
        let create = try req.content.decode(UsersDTO.Create.self)
        let hashedPassword = try await req.password.async.hash(create.password)
        let user = create.toModel(_: hashedPassword)
        try await user.create(on: req.db)
        
        return .ok
    }
    
    func login(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(Users.self)
        
        return .ok
    }
    
    func refresh(req: Request) async throws -> HTTPStatus {
        return .ok
    }
}




