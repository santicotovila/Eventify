import Foundation

enum HttpResponseCodes: Int {
    
    // MARK: - Success
    case ok = 200
    case created = 201
    case accepted = 202
    case noContent = 204
    
    // MARK: - Client Error
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case conflict = 409
    case unprocessableEntity = 422
    case tooManyRequests = 429
    
    // MARK: - Server Error
    case internalServerError = 500
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    
    var isSuccess: Bool {
        return (200...299).contains(rawValue)
    }
    
    var isClientError: Bool {
        return (400...499).contains(rawValue)
    }
    
    var isServerError: Bool {
        return (500...599).contains(rawValue)
    }
    
    var description: String {
        switch self {
        // Success
        case .ok:
            return "Success"
        case .created:
            return "Resource created successfully"
        case .accepted:
            return "Request accepted"
        case .noContent:
            return "No content"
            
        // Client Error
        case .badRequest:
            return "Bad request - Invalid parameters"
        case .unauthorized:
            return "Unauthorized - Authentication required"
        case .forbidden:
            return "Forbidden - Access denied"
        case .notFound:
            return "Resource not found"
        case .methodNotAllowed:
            return "Method not allowed"
        case .conflict:
            return "Conflict - Resource already exists"
        case .unprocessableEntity:
            return "Validation error"
        case .tooManyRequests:
            return "Too many requests - Rate limit exceeded"
            
        // Server Error
        case .internalServerError:
            return "Internal server error"
        case .badGateway:
            return "Bad gateway"
        case .serviceUnavailable:
            return "Service unavailable"
        case .gatewayTimeout:
            return "Gateway timeout"
        }
    }
}