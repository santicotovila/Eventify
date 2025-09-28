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

// MARK: - Mock Interests basados en backend real
extension InterestModel {
    static let mockInterests = [
        InterestModel(id: "A1B2C3D4-E5F6-7890-1234-567890ABCDEF", name: "Deportes", nameClean: "deportes"),
        InterestModel(id: "B2C3D4E5-F6G7-8901-2345-678901BCDEFG", name: "Juegos", nameClean: "juegos"),
        InterestModel(id: "C3D4E5F6-G7H8-9012-3456-789012CDEFGH", name: "Ferias", nameClean: "ferias"),
        InterestModel(id: "D4E5F6G7-H8I9-0123-4567-890123DEFGHI", name: "Bienestar", nameClean: "bienestar"),
        InterestModel(id: "E5F6G7H8-I9J0-1234-5678-901234EFGHIJ", name: "Música", nameClean: "musica"),
        InterestModel(id: "F6G7H8I9-J0K1-2345-6789-012345FGHIJK", name: "Cine", nameClean: "cine"),
        InterestModel(id: "G7H8I9J0-K1L2-3456-7890-123456GHIJKL", name: "Baile", nameClean: "baile"),
        InterestModel(id: "H8I9J0K1-L2M3-4567-8901-234567HIJKLM", name: "Comida", nameClean: "comida"),
        InterestModel(id: "I9J0K1L2-M3N4-5678-9012-345678IJKLMN", name: "Aprendizaje", nameClean: "aprendizaje"),
        InterestModel(id: "J0K1L2M3-N4O5-6789-0123-456789JKLMNO", name: "Aventura", nameClean: "aventura"),
        InterestModel(id: "K1L2M3N4-O5P6-7890-1234-567890KLMNOP", name: "Entrenimiento", nameClean: "entrenimiento"),
        InterestModel(id: "L2M3N4O5-P6Q7-8901-2345-678901LMNOPQ", name: "Espectáculos", nameClean: "espectaculos"),
        InterestModel(id: "M3N4O5P6-Q7R8-9012-3456-789012MNOPQR", name: "Tapas y bares", nameClean: "tapas-y-bares"),
        InterestModel(id: "N4O5P6Q7-R8S9-0123-4567-890123NOPQRS", name: "Relajación", nameClean: "relajacion"),
        InterestModel(id: "O5P6Q7R8-S9T0-1234-5678-901234OPQRST", name: "Discotecas", nameClean: "discotecas")
    ]
    
    static func cleanName(from text: String) -> String {
        var s = text.lowercased()
        s = s.folding(options: .diacriticInsensitive, locale: .init(identifier: "es_ES"))
        s = s.replacingOccurrences(of: "[^a-z0-9\\s-]", with: "", options: .regularExpression)
        s = s.replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression)
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return s
    }
}