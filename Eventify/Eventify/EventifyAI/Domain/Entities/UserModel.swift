import Foundation

// Esta clase representa a un usuario en nuestra app
// Guarda la info básica de la persona que se registró
struct UserModel: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let displayName: String?
    let createdAt: Date
    let updatedAt: Date
    
    // Esto crea un usuario nuevo con su info
    init(id: String, email: String, displayName: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Este se usa cuando sacamos un usuario de la base de datos
    init(id: String, email: String, displayName: String? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Propiedad de conveniencia para compatibilidad
    var name: String {
        return displayName ?? extractNameFromEmail()
    }
    
    private func extractNameFromEmail() -> String {
        let components = email.components(separatedBy: "@")
        if let firstComponent = components.first, !firstComponent.isEmpty {
            return firstComponent.capitalized
        }
        return "Usuario"
    }
}
