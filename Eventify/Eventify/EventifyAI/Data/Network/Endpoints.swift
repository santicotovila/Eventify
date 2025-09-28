import Foundation

enum Endpoints {
    
    // MARK: - Authentication
    case login
    case register
    case logout
    case refreshToken
    
    // MARK: - Events
    case getEvents(userId: String)
    case getEventById(eventId: String)
    case createEvent
    case updateEvent(eventId: String)
    case deleteEvent(eventId: String)
    
    
    // MARK: - User Profile
    case getUserProfile(userId: String)
    case updateUserProfile(userId: String)
    
    var path: String {
        switch self {
        // Authentication
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .logout:
            return "/auth/logout"
        case .refreshToken:
            return "/auth/refresh-token"
            
        // Eventos
        case .getEvents(let userId):
            return "/users/\(userId)/events"
        case .getEventById(let eventId):
            return "/events/\(eventId)"
        case .createEvent:
            return "/events"
        case .updateEvent(let eventId):
            return "/events/\(eventId)"
        case .deleteEvent(let eventId):
            return "/events/\(eventId)"
            
            
        // User Profile
        case .getUserProfile(let userId):
            return "/users/\(userId)"
        case .updateUserProfile(let userId):
            return "/users/\(userId)"
        }
    }
    
    var fullURL: String {
        return ConstantsApp.API.baseURL + path
    }
}
