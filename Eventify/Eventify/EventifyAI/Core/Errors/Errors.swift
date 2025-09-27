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
    case requestFailed(HttpResponseCodes)
    case noInternetConnection
    case unauthorized
    case conflict
    case internalServerError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .decodingError:
            return "Error al procesar datos"
        case .requestFailed(let statusCode):
            return "Error de red: \(statusCode.rawValue)"
        case .noInternetConnection:
            return "Sin conexión a internet"
        case .unauthorized:
            return "No autorizado"
        case .conflict:
            return "Conflicto en el servidor"
        case .internalServerError:
            return "Error interno del servidor"
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