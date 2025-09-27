//
//  EventModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 6/9/25.
//

import Foundation
struct EventModel: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let name: String? // Backend usa 'name'
    let description: String
    let date: Date
    let location: String
    let organizerId: String
    let organizerName: String
    let userID: String? // Backend requiere userID
    let category: String? // Backend requiere category UUID
    let lat: Double? // Backend requiere coordenadas
    let lng: Double? // Backend requiere coordenadas
    let isAllDay: Bool
    let tags: [String]
    let maxAttendees: Int?
    let createdAt: Date
    let updatedAt: Date
    
    var isUpcoming: Bool {
        date > Date()
    }
    
    var formattedDate: String {
        DateFormatter.eventFormatter.string(from: date)
    }
    
    var formattedTime: String {
        DateFormatter.timeFormatter.string(from: date)
    }
    
    init(id: String = UUID().uuidString, title: String, description: String, date: Date, location: String, organizerId: String, organizerName: String, userID: String? = nil, category: String? = nil, lat: Double? = nil, lng: Double? = nil, isAllDay: Bool = false, tags: [String] = [], maxAttendees: Int? = nil) {
        self.id = id
        self.title = title
        self.name = title // name = title para compatibilidad con backend
        self.description = description
        self.date = date
        self.location = location
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.userID = userID
        self.category = category
        self.lat = lat
        self.lng = lng
        self.isAllDay = isAllDay
        self.tags = tags
        self.maxAttendees = maxAttendees
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Este se usa cuando sacamos un evento de la base de datos
    init(id: String, title: String, description: String, date: Date, location: String, organizerId: String, organizerName: String, isAllDay: Bool = false, tags: [String] = [], maxAttendees: Int? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.name = title
        self.description = description
        self.date = date
        self.location = location
        self.organizerId = organizerId
        self.organizerName = organizerName
        self.userID = organizerId
        self.category = nil
        self.lat = nil
        self.lng = nil
        self.isAllDay = isAllDay
        self.tags = tags
        self.maxAttendees = maxAttendees
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Preview Extensions
extension EventModel {
    static let preview = EventModel(
        id: "preview-event-1",
        title: "Cena de Cumpleaños",
        description: "Celebremos el cumpleaños de Ana en su restaurante favorito",
        date: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date(),
        location: "Restaurante El Buen Gusto",
        organizerId: "user-preview",
        organizerName: "Ana García",
        tags: ["cumpleaños", "cena"]
    )
    
    static let previewPast = EventModel(
        id: "preview-event-2",
        title: "Reunión de Trabajo",
        description: "Reunión mensual del equipo de desarrollo",
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        location: "Oficina Central",
        organizerId: "user-preview-2",
        organizerName: "Carlos Rodríguez",
        tags: ["trabajo", "reunión"]
    )
}