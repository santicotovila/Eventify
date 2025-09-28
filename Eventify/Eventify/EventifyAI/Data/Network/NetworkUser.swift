import Foundation

final class NetworkUser {
    private let session = URLSession.shared
    private let baseURL = ConstantsApp.API.baseURL // URL del backend
    
    // MARK: - Get Interests
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
            
            // Parsear respuesta del backend
            struct InterestResponse: Codable {
                let id: UUID
                let name: String
                let nameClean: String
            }
            
            let backendInterests = try JSONDecoder().decode([InterestResponse].self, from: data)
            
            // Convertir a nuestro modelo
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
    
    // MARK: - Login User
    func login(email: String, password: String) async throws -> RegisterResponseModel {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
    
    // MARK: - Register User
    func register(name: String, email: String, password: String, interestIDs: [String]) async throws -> RegisterResponseModel {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convertir interestIDs a UUIDs
        let uuidInterests = interestIDs.compactMap { UUID(uuidString: $0) }
        
        let registerData = RegisterRequestModel(
            name: name,
            email: email,
            password: password,
            interestIDs: interestIDs
        )
        
        // Para el backend, necesitamos el formato específico
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
            
            guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
                if let responseCode = HttpResponseCodes(rawValue: httpResponse.statusCode) {
                    throw NetworkError.requestFailed(responseCode)
                } else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
            }
            
            // Parsear respuesta JWT
            return try JSONDecoder().decode(RegisterResponseModel.self, from: data)
            
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
