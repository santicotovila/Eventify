//
//  EventAttendeesDTO.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 22/9/25.
//


import Vapor

struct EventRSVPRequestDTO: Content {
    let status: EventStatus
    let userID: UUID         //REVISAR
}

struct EventRSVPResponseDTO: Content {
    let eventID: UUID
    let userID: UUID
    let status: EventStatus
    let goingCount: Int?
}
