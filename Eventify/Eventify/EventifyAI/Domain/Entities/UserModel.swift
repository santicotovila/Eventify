//
//  UserModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 6/9/25.
//

import Foundation


struct UserModel: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let displayName: String?
    let createdAt: Date
    let updatedAt: Date
    
    
    init(id: String, email: String, displayName: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    
    init(id: String, email: String, displayName: String? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    
    var name: String {
        return displayName ?? extractNameFromEmail()
    }
    
  
    private func extractNameFromEmail() -> String {
        let components = email.components(separatedBy: "@")
        if let firstComponent = components.first, !firstComponent.isEmpty {
            return firstComponent.capitalized  // Pone la primera letra en mayúscula
        }
        return "Usuario"  // Valor por defecto si algo sale mal
    }
}


extension UserModel {
    
    
    static let friendPreview1 = UserModel(
        id: "friend-1",
        email: "santi@keepcoding.com",
        displayName: "Santi Coto Vila",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let friendPreview2 = UserModel(
        id: "friend-2", 
        email: "javier@keepcoding.com",
        displayName: "Javier Gómez",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let friendPreview3 = UserModel(
        id: "friend-3",
        email: "elsa@keepcoding.com", 
        displayName: "Elsa Fernández",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let friendPreview4 = UserModel(
        id: "friend-4",
        email: "jose@gmail.com",
        displayName: "Jose Luis bustos", 
        createdAt: Date(),
        updatedAt: Date()
    )
    
    // Más usuarios para simular la funcionalidad de agregar amigos
    static let availableUser1 = UserModel(
        id: "available-1",
        email: "ana@gmail.com",
        displayName: "Ana García",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let availableUser2 = UserModel(
        id: "available-2",
        email: "carlos@gmail.com", 
        displayName: "Carlos López",
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let availableUser3 = UserModel(
        id: "available-3",
        email: "maria@gmail.com",
        displayName: "María Rodríguez", 
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let availableUser4 = UserModel(
        id: "available-4",
        email: "dani@gmail.com",
        displayName: "Dani Soler",
        createdAt: Date(),
        updatedAt: Date()
    )
}
