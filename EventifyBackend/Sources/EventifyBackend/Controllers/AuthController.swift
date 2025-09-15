import Fluent
import Vapor
import JWT
import Queues

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
    
    func register(req: Request) async throws -> JWTTokenDTO {
        
        // Validate data
        try UsersDTO.Create.validate(content: req)
        
        // Decode data and hash password
        let create = try req.content.decode(UsersDTO.Create.self)
        let hashedPassword = try await req.password.async.hash(create.password)
        
        // Save user to DB
        let user = create.toModel(withHashedPassword: hashedPassword)
        try await user.create(on: req.db)
    
        // Send email to user using Queues
        // Queues are only configured and will only work in env = production
        if req.application.environment == .production {
            try await req.queues(.email).dispatch(
                EmailJob.self,
                Email(
                    to: user.email,
                    message: "\(user.name), your user has been created successfully"
                )
            )
        }
        
        // Create and return JWT
        return try await generateJWTTokens(
            for: user.email,
            andID: user.requireID(),
            withRequest: req
        )
    }
    
    func login(req: Request) async throws -> JWTTokenDTO {
        
        let user = try req.auth.require(Users.self)
        
        return try await generateJWTTokens(
            for: user.email,
            andID: user.requireID(),
            withRequest: req
        )
    }
    
    func refresh(req: Request) async throws -> JWTTokenDTO {
        let token = try req.auth.require(JWTToken.self)
        
        guard token.isRefresh.value else {
            throw Abort(.unauthorized)
        }
        
        guard let uuid = UUID(token.userID.value) else {
            throw Abort(.unauthorized)
        }
        
        return try await generateJWTTokens(
            for: token.username.value,
            andID: uuid,
            withRequest: req
        )
    }
    
    private func generateJWTTokens(
        for username: String,
        andID userID: UUID,
        withRequest req: Request
    ) async throws -> JWTTokenDTO {
        let tokens = JWTToken.generateTokens(for: username, andID: userID)
        async let accessToken = req.jwt.sign(tokens.accessToken)
        async let refreshToken = req.jwt.sign(tokens.refreshToken)
        return try await JWTTokenDTO(accessToken: accessToken, refreshToken: refreshToken)
    }
}
