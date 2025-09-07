import Foundation

/// Errores relacionados con operaciones de red y conectividad
enum NetworkError: LocalizedError {
    case noConnection
    case timeout
    case serverError(Int)
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .noConnection:
            return "Sin conexión a internet"
        case .timeout:
            return "Tiempo de espera agotado"
        case .serverError(let code):
            return "Error del servidor (\(code))"
        case .unknownError:
            return "Error desconocido"
        }
    }
}

/// Errores relacionados con autenticación
enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case weakPassword
    case userNotFound
    case wrongPassword
    case emailAlreadyInUse
    case userDisabled
    case tooManyRequests
    case unknownAuthError
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Email no válido"
        case .invalidPassword:
            return "Contraseña no válida"
        case .weakPassword:
            return "La contraseña debe tener al menos 6 caracteres"
        case .userNotFound:
            return "Usuario no encontrado"
        case .wrongPassword:
            return "Contraseña incorrecta"
        case .emailAlreadyInUse:
            return "El email ya está registrado"
        case .userDisabled:
            return "Cuenta deshabilitada"
        case .tooManyRequests:
            return "Demasiados intentos. Intenta más tarde"
        case .unknownAuthError:
            return "Error de autenticación desconocido"
        }
    }
}

/// Errores relacionados con eventos
enum EventError: LocalizedError {
    case userNotAuthenticated
    case emptyTitle
    case titleTooShort
    case emptyDescription
    case emptyLocation
    case invalidDateTime
    case eventNotFound
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "Usuario no autenticado"
        case .emptyTitle:
            return "El título es obligatorio"
        case .titleTooShort:
            return "El título debe tener al menos 3 caracteres"
        case .emptyDescription:
            return "La descripción es obligatoria"
        case .emptyLocation:
            return "La ubicación es obligatoria"
        case .invalidDateTime:
            return "La fecha debe ser futura"
        case .eventNotFound:
            return "Evento no encontrado"
        case .permissionDenied:
            return "No tienes permisos para realizar esta acción"
        }
    }
}

/// Errores relacionados con Keychain
enum KeychainError: LocalizedError {
    case failedToSave
    case failedToLoad
    case itemNotFound
    
    var errorDescription: String? {
        switch self {
        case .failedToSave:
            return "Error al guardar en Keychain"
        case .failedToLoad:
            return "Error al cargar desde Keychain"
        case .itemNotFound:
            return "Elemento no encontrado en Keychain"
        }
    }
}