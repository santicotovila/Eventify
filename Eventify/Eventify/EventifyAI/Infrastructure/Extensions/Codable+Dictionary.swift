import Foundation

/// Extensiones para convertir entre Codable y Dictionary para Firebase
extension Encodable {
    /// Convierte el objeto a Dictionary para Firestore
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"])
        }
        return dictionary
    }
}

extension Event {
    /// Crea un Event desde un Dictionary de Firestore
    static func fromDictionary(_ dictionary: [String: Any]) throws -> Event {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(Event.self, from: data)
    }
}

extension Attendance {
    /// Crea un Attendance desde un Dictionary de Firestore
    static func fromDictionary(_ dictionary: [String: Any]) throws -> Attendance {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(Attendance.self, from: data)
    }
}

extension User {
    /// Crea un User desde un Dictionary de Firestore
    static func fromDictionary(_ dictionary: [String: Any]) throws -> User {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        return try JSONDecoder().decode(User.self, from: data)
    }
}