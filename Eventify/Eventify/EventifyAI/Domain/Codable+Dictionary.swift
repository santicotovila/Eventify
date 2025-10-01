//
//  Codable+Dictionary.swift
//  EventifyAI
//
//  Created by Javier Gómez on 15/9/25.
//

import Foundation

/// Extensiones para convertir entre Codable y Dictionary para APIs JSON
extension Encodable {
    /// Convierte el objeto a Dictionary para APIs REST
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"])
        }
        return dictionary
    }
}

extension EventModel {
    /// Crea un EventModel desde un Dictionary de API
    static func fromDictionary(_ dictionary: [String: Any]) throws -> EventModel {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(EventModel.self, from: data)
    }
}


extension UserModel {
    /// Crea un UserModel desde un Dictionary de API
    static func fromDictionary(_ dictionary: [String: Any]) throws -> UserModel {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(UserModel.self, from: data)
    }
}