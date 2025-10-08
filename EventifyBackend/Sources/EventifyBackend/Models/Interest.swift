

import Vapor
import Fluent


// Modelo que representa un interes
final class Interest: Model, @unchecked Sendable {
    static let schema = ConstantsInterests.schemaInterests
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: ConstantsInterests.name)
    var name: String
    
    
    
    @Field(key: ConstantsInterests.nameClean)
    var nameClean: String
    
    @Siblings(through: UserInterest.self, from: \.$interest, to: \.$user) // Relación muchos a muchos, un interés puede tener varios usuarios, y un usuario puede tener varios intereses.
    var users: [Users]
    
    init() {}
    init(name: String) {
        self.name = name
        self.nameClean = Interest.cleanName(from: name)
    }
    
    
    
    //Util para no diferencias por mayusculas o tildes ya que tenia conflictos.
    
    static func cleanName(from text: String) -> String {
        var s = text.lowercased()
        
        s = s.folding(options: .diacriticInsensitive, locale: .init(identifier: "es_ES"))
        s = s.replacingOccurrences(of: "[^a-z0-9\\s-]", with: "", options: .regularExpression)
       s = s.replacingOccurrences(of: "\\s+", with: "-", options: .regularExpression)
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return s
    }
    
    
    
}
