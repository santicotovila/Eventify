//
//  EventsRepositoryProtocol.swift
//  EventifyAI
//
//  Created by Javier Gómez on 7/9/25.
//

import Foundation

protocol EventsRepositoryProtocol {
    func getEvents(filter: String) async -> [EventModel]
    func createEvent(_ event: EventModel) async -> Bool
    func deleteEvent(_ eventId: String) async -> Bool
}