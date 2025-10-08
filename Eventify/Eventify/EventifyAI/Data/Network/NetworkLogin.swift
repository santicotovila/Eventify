
import Foundation

// Protocolo para servicios de red de autenticación
protocol NetworkLoginProtocol {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String, name: String) async throws -> UserModel
    func signOut() async throws
    func refreshToken() async throws -> String
}

// Servicio de red para login - maneja peticiones HTTP al backend
final class NetworkLogin: NetworkLoginProtocol {
    
    // Login usando Basic Auth - el backend espera email:password en base64
    func signIn(email: String, password: String) async throws -> UserModel {
        let baseURL = "http://localhost:8080/api"
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        // Validaciones antes de hacer la petición
        guard !email.isEmpty else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        guard password.count >= ConstantsApp.Validation.minPasswordLength else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        // Configurar URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Basic Auth: codificar email:password en base64
        let credentials = "\(email):\(password)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        do {
            // Hacer petición HTTP
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            // Manejar códigos de estado HTTP
            guard httpResponse.statusCode == 200 else {
                if httpResponse.statusCode == 401 {
                    throw NetworkError.unauthorized
                }
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            // Estructura para respuesta JWT del backend
            struct LoginResponse: Codable {
                let accessToken: String
                let refreshToken: String
            }
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Guardar token en Keychain para futuras peticiones
            try KeyChainEventify.shared.saveUserToken(loginResponse.accessToken)
            
            // Extraer ID del usuario desde el JWT payload
            let userIdFromJWT: String? = {
                guard let payload = JWTHelper.extractPayload(from: loginResponse.accessToken),
                      let userIDString = payload["userID"] as? String else {
                    return nil
                }
                return userIDString
            }()
            
            // Crear modelo de usuario con datos obtenidos
            let user = UserModel(
                id: userIdFromJWT ?? "user-fallback-\(UUID().uuidString)",
                email: email,
                displayName: email.components(separatedBy: "@").first ?? "Usuario"
            )
            
            return user
            
        } catch {
            if error is NetworkError {
                throw error
            } else {
                throw NetworkError.decodingError(error)
            }
        }
    }
    
    // Método deprecado - ahora el registro se hace desde NetworkUser
    func signUp(email: String, password: String, name: String) async throws -> UserModel {
        // Ya no se usa este método, registro se hace en NetworkUser.register()
        throw NetworkError.requestFailed(.badRequest)
    }
    
    // Logout - en este caso solo simula el proceso
    func signOut() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // Renovar token JWT - por ahora es mock
    func refreshToken() async throws -> String {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return "mock-jwt-token-\(UUID().uuidString)"
    }
}
