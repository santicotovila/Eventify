import Foundation
import SwiftData

//   Repository híbrido: Amigos ficticios + SwiftData para amigos nuevos
final class HybridFriendsRepository {
    
    // Amigos ficticios para demo
    private let mockFriends = [
        UserModel.friendPreview1, // Santi Coto Vila
        UserModel.friendPreview2, // Javier Gómez
        UserModel.friendPreview3, // Elsa Fernández
        UserModel.friendPreview4  // Jose Luis Bustos
    ]
    
    // Usuarios disponibles para agregar
    private let availableUsers = [
        UserModel.availableUser1, // Ana García
        UserModel.availableUser2, // Carlos López
        UserModel.availableUser3, // María Rodríguez
        UserModel.availableUser4  // Dani Soler
    ]
    
    // Amigos reales añadidos (en memoria por ahora)
    private var realFriends: [UserModel] = []
    
    // SwiftData para persistencia (futuro)
    private let modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    // MARK: - Get Friends
    func getFriends(filter: String = "") -> [UserModel] {
        var allFriends: [UserModel] = []
        
        // 1. Siempre incluir amigos mockeados para demo
        allFriends.append(contentsOf: mockFriends)
        
        // 2. Agregar amigos reales añadidos
        allFriends.append(contentsOf: realFriends)
        
        // 3. Filtrar si hay búsqueda
        let filteredFriends = filter.isEmpty ? allFriends : allFriends.filter { friend in
            friend.name.lowercased().contains(filter.lowercased()) ||
            friend.email.lowercased().contains(filter.lowercased())
        }
        
        // 4. Ordenar alfabéticamente
        return filteredFriends.sorted { $0.name < $1.name }
    }
    
    // MARK: - Available Users to Add
    func getAvailableUsers(filter: String = "") -> [UserModel] {
        let currentFriendsIds = Set(getFriends().map { $0.id })
        
        // Filtrar usuarios que NO son amigos todavía
        let availableFiltered = availableUsers.filter { user in
            !currentFriendsIds.contains(user.id)
        }
        
        // Aplicar filtro de búsqueda
        let searchFiltered = filter.isEmpty ? availableFiltered : availableFiltered.filter { user in
            user.name.lowercased().contains(filter.lowercased()) ||
            user.email.lowercased().contains(filter.lowercased())
        }
        
        return searchFiltered.sorted { $0.name < $1.name }
    }
    
    // MARK: - Add Friend
    func addFriend(_ user: UserModel) -> Bool {
        // Verificar que no sea ya amigo
        let currentFriendsIds = Set(getFriends().map { $0.id })
        guard !currentFriendsIds.contains(user.id) else {
            return false
        }
        
        // Añadir a amigos reales
        realFriends.append(user)
        
        
        return true
    }
    
    // MARK: - Remove Friend
    func removeFriend(userId: String) -> Bool {
        // Proteger amigos mockeados (como con eventos)
        let protectedIds = ["friend-1", "friend-2", "friend-3", "friend-4"]
        
        if protectedIds.contains(userId) {
            return false
        }
        
        // Eliminar de amigos reales
        if let index = realFriends.firstIndex(where: { $0.id == userId }) {
            realFriends.remove(at: index)
            return true
        }
        return false
    }
}
