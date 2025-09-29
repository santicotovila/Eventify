//
//  NetworkLogin.swift
//  EventifyAI
//
//  Created by Javier Gómez on 14/9/25.
//

import Foundation

protocol NetworkLoginProtocol {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String, name: String) async throws -> UserModel
    func signOut() async throws
    func refreshToken() async throws -> String
}

final class NetworkLogin: NetworkLoginProtocol {
    
    func signIn(email: String, password: String) async throws -> UserModel {
        let baseURL = "http://localhost:8080/api"
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidURL
        }
        
        guard !email.isEmpty else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        guard password.count >= ConstantsApp.Validation.minPasswordLength else {
            throw NetworkError.requestFailed(.badRequest)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethods.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Crear credenciales para basic auth (como espera el backend)
        let credentials = "\(email):\(password)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            
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
            
            // Parsear respuesta JWT
            struct LoginResponse: Codable {
                let accessToken: String
                let refreshToken: String
            }
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            // Guardar el token JWT en KeyChain
            try KeyChainEventify.shared.saveUserToken(loginResponse.accessToken)
            
            // Extraer userID del JWT token
            let userIdFromJWT: String? = {
                guard let payload = JWTHelper.extractPayload(from: loginResponse.accessToken),
                      let userIDString = payload["userID"] as? String else {
                    return nil
                }
                return userIDString
            }()
            
            // Crear UserModel con el ID real del JWT
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
    
    func signUp(email: String, password: String, name: String) async throws -> UserModel {
        // Este método está deprecated. 
        // Use NetworkUser.register() para registro con intereses
        throw NetworkError.requestFailed(.badRequest)
    }
    
    func signOut() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    func refreshToken() async throws -> String {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        return "mock-jwt-token-\(UUID().uuidString)"
    }
}