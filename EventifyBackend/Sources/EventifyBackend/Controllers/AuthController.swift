import Fluent
import Vapor
import JWT
import Queues

// Controlador de autenticación con  RouteCollection para registrar la ruta.
struct AuthController: RouteCollection {
    // Se llama al arrancar para registrar las rutas.
    func boot(routes: any RoutesBuilder) throws {
        // Agrupa todas las rutas bajo el prefijo /auth
        routes.group("auth") { builder in
            // POST /auth/register -> Registro de usuarios
            builder.post("register", use: register)
            
            // POST /auth/refresh - Emisión de nuevos tokens usando un refresh token
            builder.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { protected in
                protected.post("refresh", use: refresh)
            }
            
            // Agrupamos rutas que requieren autenticación básica del modelo Users.
            builder.group(Users.authenticator(), Users.guardMiddleware()) { protected in
                // POST /auth/login -> Emisión de tokens JWT para un usuario autenticado
                protected.post("login", use: login)
            }
        }
    }
}

extension AuthController {
    
    // Endpoint de registro de usuarios
    func register(req: Request) async throws -> JWTTokenDTO {
        
        // Validar el contenido del request
        try UsersDTO.Create.validate(content: req)
        
        //  Decodificar el DTO y hashear la contraseña
        let create = try req.content.decode(UsersDTO.Create.self)
        let hashedPassword = try await req.password.async.hash(create.password)
        
        // Mapear el DTO al modelo Users con la contraseña hashead y guardar en base de datos
        let user = create.toModel(withHashedPassword: hashedPassword)
        try await user.create(on: req.db)
    
        //  Enviar email usando Queues en entorno de producción
        if req.application.environment == .production {
            try await req.queues(.email).dispatch(
                EmailJob.self,
                Email(
                    to: user.email,
                    message: "\(user.name), your user has been created successfully"
                )
            )
        }
        
        //  Generar y devuelve ambos tokens JWT
        return try await generateJWTTokens(
            for: user.email,
            andID: user.requireID(),
            withRequest: req
        )
    }
    
    // Endpoint de login.
    // Requiere que el middleware de autenticación haya adjuntado un Users válido al request.
    // Si llega aquí, el usuario está autenticado y se emiten tokens JWT.
        func login(req: Request) async throws -> JWTTokenDTO {
            
            // Recuperamos el usuario autenticado
            let user = try req.auth.require(Users.self)
            
            // Genera y devuelve tokens para el usuario
            return try await generateJWTTokens(
                for: user.email,
                andID: user.requireID(),
                withRequest: req
            )
        }
    
    // Endpoint de refresh token.
    // Recibe un JWT en el Authorization que debe ser un refresh token válido.
    // Emite un nuevo par de tokens (access + refresh).
    func refresh(req: Request) async throws -> JWTTokenDTO {
        let token = try req.auth.require(JWTToken.self)
        
        // Asegura que el token entrante es de tipo "refresh"
        guard token.isRefresh.value else {
            throw Abort(.unauthorized)
        }
        
        // Convierte el userID (string) a UUID
        guard let uuid = UUID(token.userID.value) else {
            throw Abort(.unauthorized)
        }
        
        // Emite nuevos tokens para ese usuario
        return try await generateJWTTokens(
            for: token.username.value,
            andID: uuid,
            withRequest: req
        )
    }
    
    
    
    // Devuelve un DTO con las cadenas firmadas (accessToken y refreshToken).
    private func generateJWTTokens(
        for username: String,
        andID userID: UUID,
        withRequest req: Request
    ) async throws -> JWTTokenDTO {
      
        let tokens = JWTToken.generateTokens(for: username, andID: userID)
        
        // Firma ambos tokens en paralelo para optimizar
        async let accessToken = req.jwt.sign(tokens.accessToken)
        async let refreshToken = req.jwt.sign(tokens.refreshToken)
        
        return try await JWTTokenDTO(accessToken: accessToken, refreshToken: refreshToken)
    }
}

