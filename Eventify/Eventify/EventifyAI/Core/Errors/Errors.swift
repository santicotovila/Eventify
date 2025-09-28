//
//  Errors.swift
//  EventifyAI
//
//  Created by Javier Gómez on 5/9/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case decodingError(Error)
    case badRequest(String)
    case unauthorized
    case notFound
    case internalServerError
    case noInternetConnection
    case requestFailed(HttpResponseCodes)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .decodingError:
            return "Error al procesar datos"
        case .badRequest(let message):
            return "Validaciones o IDs mal formados: \(message)"
        case .unauthorized:
            return "Token ausente/expirado o API Key inválida"
        case .notFound:
            return "Recurso inexistente"
        case .internalServerError:
            return "Errores internos del servidor"
        case .noInternetConnection:
            return "Sin conexión a internet"
        case .requestFailed(let statusCode):
            return "Error de red: \(statusCode.rawValue)"
        case .unknown:
            return "Error de red"
        }
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case weakPassword
    case networkError(NetworkError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email o contraseña incorrectos"
        case .emailAlreadyInUse:
            return "Email ya registrado"
        case .weakPassword:
            return "Contraseña debe tener al menos 6 caracteres"
        case .networkError(let networkError):
            return networkError.localizedDescription
        case .unknown:
            return "Error de autenticación"
        }
    }
}

enum EventError: LocalizedError {
    case eventNotFound
    case eventCreationFailed(String)
    case networkError(NetworkError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .eventNotFound:
            return "Evento no encontrado"
        case .eventCreationFailed(let reason):
            return "Error al crear evento: \(reason)"
        case .networkError(let networkError):
            return networkError.localizedDescription
        case .unknown:
            return "Error en evento"
        }
    }
}