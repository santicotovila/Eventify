
import Foundation
import Fluent

struct PopulateData: AsyncMigration {
    func revert(on database: any FluentKit.Database) async throws {
        // Limpia la tabla de intereses al revertir esta migración.
        try await Interest.query(on: database).delete()
    }
    
    
    func prepare(on database: any Database) async throws {
        // Lista de intereses iniciales para el registro del usuario.
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
        
        // Inserta cada interés si no existe previamente
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
