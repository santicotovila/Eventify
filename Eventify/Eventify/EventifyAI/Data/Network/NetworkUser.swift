import Foundation

// Servicio de red para operaciones de usuario - intereses y registro
final class NetworkUser {
    private let session = URLSession.shared
    private let baseURL = ConstantsApp.API.baseURL
    
    // MARK: - Obtener lista de intereses disponibles
    func getInterests() async throws -> [InterestModel] {
        guard let url = URL(string: "\(baseURL)/interests") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.GET.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            // Estructura que espera el backend para intereses
            struct InterestResponse: Codable {
                let id: UUID
                let name: String
                let nameClean: String
            }
            
            let backendInterests = try JSONDecoder().decode([InterestResponse].self, from: data)
            
            // Convertir formato del backend a nuestro modelo de app
            return backendInterests.map { interest in
                InterestModel(
                    id: interest.id.uuidString,
                    name: interest.name,
                    nameClean: interest.nameClean
                )
            }
            
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Login con JSON en body (método alternativo al Basic Auth)
    func login(email: String, password: String) async throws -> RegisterResponseModel {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Datos de login en JSON (diferente a Basic Auth)
        struct LoginRequest: Codable {
            let email: String
            let password: String
        }
        
        let loginData = LoginRequest(email: email, password: password)
        
        do {
            let jsonData = try JSONEncoder().encode(loginData)
            request.httpBody = jsonData
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            guard httpResponse.statusCode == 200 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            return try JSONDecoder().decode(RegisterResponseModel.self, from: data)
            
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Registro de usuario con intereses seleccionados
    func register(name: String, email: String, password: String, interestIDs: [String]) async throws -> RegisterResponseModel {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convertir IDs de String a UUID para el backend
        let uuidInterests = interestIDs.compactMap { UUID(uuidString: $0) }
        
        // Modelo de nuestra app (String IDs)
        let registerData = RegisterRequestModel(
            name: name,
            email: email,
            password: password,
            interestIDs: interestIDs
        )
        
        // Formato específico que espera el backend (UUID IDs)
        struct BackendRegisterRequest: Codable {
            let name: String
            let email: String
            let password: String
            let interestIDs: [UUID]
        }
        
        let backendRequest = BackendRegisterRequest(
            name: name,
            email: email,
            password: password,
            interestIDs: uuidInterests
        )
        
        do {
            let jsonData = try JSONEncoder().encode(backendRequest)
            request.httpBody = jsonData
            
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
            // Aceptar tanto 200 como 201 para registro exitoso
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            // Parsear respuesta con token JWT del usuario registrado
            return try JSONDecoder().decode(RegisterResponseModel.self, from: data)
            
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
