
import Foundation

// Estado de asistencia de usuarios.

enum EventStatus: String, Codable, CaseIterable {
    case going, maybe, declined
}
