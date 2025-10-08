

import Vapor

// Para adjuntar o quitar un interés a un usuario
struct UserInterestLinkDTO: Content {
    let userID: UUID
    let interestID: UUID
}

// Para responder intereses de un usuario
struct UserInterestsResponseDTO: Content {
    let userID: UUID
    let interests: [InterestUsersResponseDTO]
}

// Para responder, usuarios que tienen un interés
struct InterestUsersResponseDTO: Content {
    let interestID: UUID
    let users: [UserMiniDTO]
}

// Respuesta mini de usuario  para donde necesito su respecto id y name solamente.
struct UserMiniDTO: Content {
    let id: UUID
    let name: String
}
