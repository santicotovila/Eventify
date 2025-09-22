//
//  EventsDTO.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//
//


import Vapor
import Foundation

struct EventsDTO: Content {
    struct Create: Content {
        let name: String
        let category: String
        let userID: UUID
        let lat: Double?
        let lng: Double?

        func toModel() -> Events {
            Events(
                name: name,
                category: category,
                userID: userID,
                lat: lat,
                lng: lng
            )
        }
    }

    struct Update: Content {
        let name: String?
        let category: String?
        let lat: Double?
        let lng: Double?
    }

    struct Public: Content {
        let id: UUID
        let name: String
        let category: String
        let lat: Double?
        let lng: Double?
        let userID: UUID
        let createdAt: Date?
        let updatedAt: Date?
    }


}

// Validaciones
extension EventsDTO.Create: Validatable {
    static func validations(_ v: inout Validations) {
        v.add("name", as: String.self, is: .count(1...), required: true)
        v.add("category", as: String.self, is: .count(1...), required: true)
        v.add("lat", as: Double?.self, is: .nil || .range(-90...90))
        v.add("lng", as: Double?.self, is: .nil || .range(-180...180))
    }
}

extension EventsDTO.Update: Validatable {
    static func validations(_ v: inout Validations) {
        v.add("name", as: String?.self, is: .nil || .count(1...))
        v.add("category", as: String?.self, is: .nil || .count(1...))
        v.add("lat", as: Double?.self, is: .nil || .range(-90...90))
        v.add("lng", as: Double?.self, is: .nil || .range(-180...180))
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
            updatedAt: updatedAt
        )
    }
}
