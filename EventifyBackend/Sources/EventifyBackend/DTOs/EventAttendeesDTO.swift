//
//  EventAttendeesDTO.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 22/9/25.



import Vapor

// MARK: - DTOs de asistencia a eventos (RSVP)
struct EventAttendeesDTO: Content {
 
    struct Create: Content {
        let eventID: UUID
        let userID: UUID
        let status: EventStatus
    }

    struct CreateFromJWT: Content {
        let eventID: UUID
        let status: EventStatus
    }

    struct Update: Content {
        let status: EventStatus
    }

  
    struct Public: Content {
        let id: UUID
        let eventID: UUID
        let userID: UUID
        let status: EventStatus
        let joinedAt: Date?
        let updatedAt: Date?
    }
}

// MARK: - Validations
extension EventAttendeesDTO.Create: Validatable {
    static func validations(_ v: inout Validations) {
        v.add("eventID", as: UUID.self, required: true)
        v.add("userID",  as: UUID.self, required: true)
    
    }
}
extension EventAttendeesDTO.CreateFromJWT: Validatable {
    static func validations(_ v: inout Validations) {
        v.add("eventID", as: UUID.self, required: true)
    }
}
