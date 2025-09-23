//
//  EventAttendeesDTO.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 22/9/25.
//


import Vapor

// MARK: - DTOs de asistencia a eventos (RSVP)
struct EventAttendeesDTO: Content {
    // Crear/registrar asistencia (versión simple: trae userID en el body)
    struct Create: Content {
        let eventID: UUID
        let userID: UUID
        let status: EventStatus
    }

    // Crear/registrar asistencia (si usas JWT y NO quieres userID en el body)
    // -> en el handler sacas userID del token
    struct CreateFromJWT: Content {
        let eventID: UUID
        let status: EventStatus
    }

    // Cambiar el estado (going/maybe/declined)
    struct Update: Content {
        let status: EventStatus
    }

    // Lo que devuelves al cliente
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
        // status se valida por el enum (Codable) al decodificar
    }
}
extension EventAttendeesDTO.CreateFromJWT: Validatable {
    static func validations(_ v: inout Validations) {
        v.add("eventID", as: UUID.self, required: true)
    }
}
extension EventAttendeesDTO.Update: Validatable {
    static func validations(_ v: inout Validations) {
        // nada extra; el enum ya valida
    }
}
