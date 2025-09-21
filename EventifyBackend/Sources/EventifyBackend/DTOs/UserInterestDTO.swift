//
//  UserInterestDTO.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Vapor

// Para adjuntar o quitar un interés a un usuario
struct UserInterestLinkDTO: Content {
    let userID: UUID
    let interestID: UUID
}

// Para responder: intereses de un usuario
struct UserInterestsResponseDTO: Content {
    let userID: UUID
    let interests: [InterestResponseDTO]
}

// Para responder: usuarios que tienen un interés
struct InterestUsersResponseDTO: Content {
    let interestID: UUID
    let users: [UserMiniDTO]
}

// Respuesta mini de usuario 
struct UserMiniDTO: Content {
    let id: UUID
    let name: String
}
