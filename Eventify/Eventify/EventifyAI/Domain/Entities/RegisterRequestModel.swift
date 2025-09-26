import Foundation

// Modelo para enviar datos de registro al backend
struct RegisterRequestModel: Codable {
    let name: String
    let email: String
    let password: String
    let interestIDs: [String] // UUIDs como strings
}

// Modelo de respuesta del registro (JWT Token)
struct RegisterResponseModel: Codable {
    let accessToken: String
    let refreshToken: String
}