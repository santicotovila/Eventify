//
//  InterestModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 6/9/25.
//

import Foundation
struct InterestModel: Identifiable, Codable, Hashable {
    let id: String // UUID como string
    let name: String
    let nameClean: String
    
    // Para usar en UI
    var displayName: String {
        return name
    }
}

// MARK: - Mock Interests para testing
extension InterestModel {
    static let mockInterests = [
        InterestModel(id: UUID().uuidString, name: "Deportes", nameClean: "deportes"),
        InterestModel(id: UUID().uuidString, name: "Música", nameClean: "musica"),
        InterestModel(id: UUID().uuidString, name: "Cine", nameClean: "cine"),
        InterestModel(id: UUID().uuidString, name: "Tecnología", nameClean: "tecnologia"),
        InterestModel(id: UUID().uuidString, name: "Arte", nameClean: "arte"),
        InterestModel(id: UUID().uuidString, name: "Cocina", nameClean: "cocina"),
        InterestModel(id: UUID().uuidString, name: "Viajes", nameClean: "viajes"),
        InterestModel(id: UUID().uuidString, name: "Literatura", nameClean: "literatura"),
        InterestModel(id: UUID().uuidString, name: "Gaming", nameClean: "gaming"),
        InterestModel(id: UUID().uuidString, name: "Fotografía", nameClean: "fotografia"),
    ]
}