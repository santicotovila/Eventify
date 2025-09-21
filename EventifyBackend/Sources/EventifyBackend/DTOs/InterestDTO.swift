//
//  InterestDTO.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Vapor

// Para crear un interés (solo mandas el name; nameClean se calcula en el modelo)
struct InterestDTO: Content {
    let name: String
}

// Para actualizar (opcional, normalmente solo el name)
struct InterestUpdateDTO: Content {
    let name: String
}

// Para responder al cliente
struct InterestResponseDTO: Content {
    let id: UUID
    let name: String
    let nameClean: String
}

// Mapeos Modelo -> DTO
extension Interest {
    func toResponseDTO() throws -> InterestResponseDTO {
        InterestResponseDTO(
            id: try self.requireID(),
            name: self.name,
            nameClean: self.nameClean
        )
    }
}
