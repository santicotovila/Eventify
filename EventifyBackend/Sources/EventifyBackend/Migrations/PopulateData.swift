//
//  PopulateData.swift
//  EventifyBackend
//
//  Created by Santiago Coto Vila on 23/9/25.
//

import Foundation
import Fluent

struct PopulateData: AsyncMigration {
    func revert(on database: any FluentKit.Database) async throws {
        try await Interest.query(on: database).delete()
    }
    
    
    func prepare(on database: any Database) async throws {
        let nameInterests = ["Deportes",
                             "Juegos",
                             "Ferias",
                             "Bienestar",
                             "Música",
                             "Cine",
                             "Baile",
                             "Comida",
                             "Aprendizaje",
                             "Aventura",
                             "Entrenimiento",
                             "Espectáculos",
                             "Tapas y bares",
                             "Relajación",
                             "Discotecas"]
        
        for name in nameInterests {
            if try await Interest.query(on: database)
                .filter(\.$name == name)
                .first() == nil {
                let interests = Interest(name: name)
                try await interests.create(on:database)
                
            }
        }
       
    }
}
