//
//  Interest.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 21/9/25.
//

import Vapor
import Fluent

final class Interest: Model, @unchecked Sendable {
    static let schema = ConstantsInterests.schemaInterests
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: ConstantsInterests.name)
    var name: String
    
    
    
    @Field(key: ConstantsInterests.nameClean)
    var nameClean: String
    
    @Siblings(through: UserInterest.self, from: \.$interest, to: \.$user)
    var users: [Users]
    
    init() {}
    init(name: String) {
        self.name = name
        self.nameClean = Interest.cleanName(from: name)
    }
    
    
    
    //MARK: - Util para no diferencias por mayusculas o tildes
    
    
    static func cleanName(from text: String) -> String {
        var s = text.lowercased()
        // quita tildes: "Música" -> "Musica"
        s = s.folding(options: .diacriticInsensitive, locale: .init(identifier: "es_ES"))
        // deja solo letras/números/espacios/guiones
        s = s.replacingOccurrences(of: "[^a-z0-9\\s-]", with: "", options: .regularExpression)
        // espacios múltiples -> un guion
        s = s.replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression)
        // quita guiones al principio/fin
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return s
    }
    
    
    
}
