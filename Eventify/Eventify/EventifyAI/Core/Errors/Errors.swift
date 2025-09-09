import Foundation

/// Errores relacionados con operaciones de red y conectividad
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case requestFailed(HttpResponseCodes)
    case noInternetConnection
    case timeout
    case serverError(String)
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case tooManyRequests
    case internalServerError
    case serviceUnavailable
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "La URL proporcionada no es válida"
        case .noData:
            return "No se recibieron datos del servidor"
        case .decodingError(let error):
            return "Error al procesar los datos: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Error al preparar los datos: \(error.localizedDescription)"
        case .requestFailed(let statusCode):
            return "La solicitud falló con código: \(statusCode.rawValue)"
        case .noInternetConnection:
            return "No hay conexión a internet"
        case .timeout:
            return "La solicitud excedió el tiempo de espera"
        case .serverError(let message):
            return "Error del servidor: \(message)"
        case .unauthorized:
            return "No tienes autorización para realizar esta acción"
        case .forbidden:
            return "Acceso denegado"
        case .notFound:
            return "El recurso solicitado no fue encontrado"
        case .conflict:
            return "Conflicto en la solicitud"
        case .tooManyRequests:
            return "Demasiadas solicitudes. Intenta más tarde"
        case .internalServerError:
            return "Error interno del servidor"
        case .serviceUnavailable:
            return "Servicio no disponible temporalmente"
        case .unknown(let error):
            return "Error desconocido: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Verifica tu conexión a internet e intenta nuevamente"
        case .timeout:
            return "Intenta nuevamente en unos momentos"
        case .unauthorized:
            return "Inicia sesión nuevamente"
        case .tooManyRequests:
            return "Espera unos minutos antes de intentar nuevamente"
        case .serviceUnavailable:
            return "El servicio está temporalmente no disponible. Intenta más tarde"
        default:
            return "Intenta nuevamente más tarde"
        }
    }
}

/// Errores relacionados con autenticación
enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case emailNotVerified
    case accountDisabled
    case tokenExpired
    case invalidToken
    case networkError(NetworkError)
    case biometricAuthFailed
    case biometricNotAvailable
    case biometricNotEnrolled
    case userCancelled
    case signOutFailed
    case accountCreationFailed(String)
    case passwordResetFailed
    case keychainError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Credenciales inválidas. Verifica tu email y contraseña"
        case .userNotFound:
            return "Usuario no encontrado"
        case .emailAlreadyInUse:
            return "Este email ya está registrado"
        case .weakPassword:
            return "La contraseña debe tener al menos 6 caracteres"
        case .emailNotVerified:
            return "Verifica tu email antes de continuar"
        case .accountDisabled:
            return "Esta cuenta ha sido deshabilitada"
        case .tokenExpired:
            return "Tu sesión ha expirado. Inicia sesión nuevamente"
        case .invalidToken:
            return "Token de autenticación inválido"
        case .networkError(let networkError):
            return "Error de red: \(networkError.localizedDescription)"
        case .biometricAuthFailed:
            return "Autenticación biométrica falló"
        case .biometricNotAvailable:
            return "Autenticación biométrica no disponible"
        case .biometricNotEnrolled:
            return "No hay datos biométricos configurados"
        case .userCancelled:
            return "Operación cancelada por el usuario"
        case .signOutFailed:
            return "Error al cerrar sesión"
        case .accountCreationFailed(let reason):
            return "No se pudo crear la cuenta: \(reason)"
        case .passwordResetFailed:
            return "No se pudo restablecer la contraseña"
        case .keychainError(let error):
            return "Error de almacenamiento seguro: \(error.localizedDescription)"
        case .unknown(let error):
            return "Error de autenticación: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Verifica que tu email y contraseña sean correctos"
        case .emailAlreadyInUse:
            return "Intenta iniciar sesión o usar otro email"
        case .weakPassword:
            return "Usa una contraseña más segura con al menos 6 caracteres"
        case .emailNotVerified:
            return "Revisa tu bandeja de entrada y verifica tu email"
        case .tokenExpired:
            return "Inicia sesión nuevamente"
        case .biometricNotAvailable:
            return "Usa tu contraseña para iniciar sesión"
        case .biometricNotEnrolled:
            return "Configura Touch ID o Face ID en Configuración"
        case .passwordResetFailed:
            return "Intenta nuevamente o contacta soporte"
        default:
            return "Intenta nuevamente más tarde"
        }
    }
}

/// Errores relacionados con eventos
enum EventError: LocalizedError {
    case eventNotFound
    case eventAlreadyExists
    case invalidEventData(String)
    case eventInThePast
    case maxAttendeesReached
    case userAlreadyRegistered
    case userNotRegistered
    case organizerCannotUnregister
    case eventCancelled
    case eventFull
    case registrationClosed
    case attendanceUpdateFailed
    case invalidAttendanceStatus
    case eventCreationFailed(String)
    case eventUpdateFailed(String)
    case eventDeletionFailed(String)
    case permissionDenied
    case networkError(NetworkError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .eventNotFound:
            return "Evento no encontrado"
        case .eventAlreadyExists:
            return "Ya existe un evento con estos datos"
        case .invalidEventData(let message):
            return "Datos del evento inválidos: \(message)"
        case .eventInThePast:
            return "No se puede crear un evento en el pasado"
        case .maxAttendeesReached:
            return "Se alcanzó el máximo de participantes"
        case .userAlreadyRegistered:
            return "Ya estás registrado en este evento"
        case .userNotRegistered:
            return "No estás registrado en este evento"
        case .organizerCannotUnregister:
            return "El organizador no puede desregistrarse de su propio evento"
        case .eventCancelled:
            return "Este evento ha sido cancelado"
        case .eventFull:
            return "El evento está lleno"
        case .registrationClosed:
            return "El registro para este evento está cerrado"
        case .attendanceUpdateFailed:
            return "No se pudo actualizar tu asistencia"
        case .invalidAttendanceStatus:
            return "Estado de asistencia inválido"
        case .eventCreationFailed(let reason):
            return "No se pudo crear el evento: \(reason)"
        case .eventUpdateFailed(let reason):
            return "No se pudo actualizar el evento: \(reason)"
        case .eventDeletionFailed(let reason):
            return "No se pudo eliminar el evento: \(reason)"
        case .permissionDenied:
            return "No tienes permisos para realizar esta acción"
        case .networkError(let networkError):
            return "Error de red: \(networkError.localizedDescription)"
        case .unknown(let error):
            return "Error en evento: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .eventInThePast:
            return "Selecciona una fecha futura para el evento"
        case .maxAttendeesReached, .eventFull:
            return "Intenta registrarte en otro evento similar"
        case .userAlreadyRegistered:
            return "Puedes cambiar tu estado de asistencia si es necesario"
        case .registrationClosed:
            return "Contacta al organizador si necesitas registrarte"
        case .permissionDenied:
            return "Solo el organizador puede realizar esta acción"
        case .attendanceUpdateFailed:
            return "Intenta actualizar tu asistencia nuevamente"
        default:
            return "Intenta nuevamente más tarde"
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

/// Errores de lógica de dominio y validación
enum DomainError: LocalizedError {
    case invalidInput(String)
    case businessRuleViolation(String)
    case entityNotFound(String)
    case entityAlreadyExists(String)
    case operationNotAllowed(String)
    case dataCorrupted(String)
    case mappingFailed(String)
    case validationFailed([ValidationError])
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Entrada inválida: \(message)"
        case .businessRuleViolation(let message):
            return "Regla de negocio violada: \(message)"
        case .entityNotFound(let entityName):
            return "\(entityName) no encontrado"
        case .entityAlreadyExists(let entityName):
            return "\(entityName) ya existe"
        case .operationNotAllowed(let message):
            return "Operación no permitida: \(message)"
        case .dataCorrupted(let message):
            return "Datos corruptos: \(message)"
        case .mappingFailed(let message):
            return "Error al mapear datos: \(message)"
        case .validationFailed(let errors):
            let messages = errors.map { $0.message }.joined(separator: ", ")
            return "Validación falló: \(messages)"
        }
    }
}

struct ValidationError {
    let field: String
    let message: String
    
    init(field: String, message: String) {
        self.field = field
        self.message = message
    }
}

/// Errores relacionados con asistencia a eventos
enum AttendanceError: LocalizedError {
    case attendanceNotFound
    case attendanceAlreadyExists
    case invalidAttendanceData(String)
    case userNotRegistered
    case attendanceFetchFailed(String)
    case attendanceSaveFailed(String)
    case attendanceDeleteFailed(String)
    case networkError(NetworkError)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .attendanceNotFound:
            return "Registro de asistencia no encontrado"
        case .attendanceAlreadyExists:
            return "Ya existe un registro de asistencia para este usuario"
        case .invalidAttendanceData(let message):
            return "Datos de asistencia inválidos: \(message)"
        case .userNotRegistered:
            return "El usuario no está registrado en este evento"
        case .attendanceFetchFailed(let reason):
            return "No se pudo obtener la asistencia: \(reason)"
        case .attendanceSaveFailed(let reason):
            return "No se pudo guardar la asistencia: \(reason)"
        case .attendanceDeleteFailed(let reason):
            return "No se pudo eliminar la asistencia: \(reason)"
        case .networkError(let networkError):
            return "Error de red: \(networkError.localizedDescription)"
        case .unknown(let error):
            return "Error de asistencia: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .userNotRegistered:
            return "Regístrate primero en el evento antes de marcar tu asistencia"
        case .attendanceAlreadyExists:
            return "Puedes actualizar tu estado de asistencia existente"
        default:
            return "Intenta nuevamente más tarde"
        }
    }
}