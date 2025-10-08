

import Vapor
import Foundation

//Conversiones de Events con sus respectivas validaciones.
struct EventsDTO: Content {
    struct Create: Content {
        let name: String
        let category: String?
        let userID: UUID
        let eventDate: Date?
        let location: String?
        let lat: Double?
        let lng: Double?

        func toModel() -> Events {
            Events(
                name: name,
                category: category,
                userID: userID,
                lat: lat,
                lng: lng,
                eventDate: eventDate,
                location: location
                
            )
        }
    }

    struct Update: Content {
        let name: String?
        let category: String?
        let eventDate: Date?
        let lat: Double?
        let lng: Double?
        let location: String?
    }

    struct Public: Content {
        let id: UUID
        let name: String
        let category: String?
        let lat: Double?
        let lng: Double?
        let userID: UUID
        let createdAt: Date?
        let updatedAt: Date?
        let eventDate: Date?
        let location: String?
    }


}

// Validaciones para events
extension EventsDTO.Create: Validatable {
    static func validations(_ v: inout Validations) {
        v.add("name", as: String.self, is: .count(1...), required: true)
        v.add("category", as: String.self, is: .count(1...), required: false)
      //  v.add("lat", as: Double?.self, is: .nil || .range(-90...90))
      //  v.add("lng", as: Double?.self, is: .nil || .range(-180...180))
    }
}

extension EventsDTO.Update: Validatable {
    static func validations(_ v: inout Validations) {
        v.add("name", as: String?.self, is: .nil || .count(1...))
        v.add("category", as: String?.self, is: .nil || .count(1...))
     //   v.add("lat", as: Double?.self, is: .nil || .range(-90...90))
       // v.add("lng", as: Double?.self, is: .nil || .range(-180...180))
        
    }
}

extension Events {
    func toPublicDTO() throws -> EventsDTO.Public {
        EventsDTO.Public(
            id: try requireID(),
            name: name,
            category: category,
            lat: lat,
            lng: lng,
            userID: $user.id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            eventDate: eventDate,
            location: location
        )
    }
}
