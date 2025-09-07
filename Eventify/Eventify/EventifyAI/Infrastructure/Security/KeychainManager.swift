import Foundation
import Security

/// Protocolo que define las operaciones del Keychain
protocol KeychainManagerProtocol {
    func save(key: String, data: String) throws
    func load(key: String) -> String?
    func delete(key: String)
}

/// Manager para operaciones seguras de Keychain
/// Utiliza Security framework para almacenar credenciales de forma segura
final class KeychainManager: KeychainManagerProtocol {
    
    // MARK: - Constants
    private let service = "com.eventify.app"
    
    // MARK: - Public Methods
    
    /// Guarda un string en el Keychain de forma segura
    /// - Parameters:
    ///   - key: Clave única para identificar el dato
    ///   - data: String a guardar
    func save(key: String, data: String) throws {
        let data = Data(data.utf8)
        
        // Crear query para el Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Eliminar elemento existente si existe
        SecItemDelete(query as CFDictionary)
        
        // Agregar nuevo elemento
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // Verificar si la operación fue exitosa
        guard status == errSecSuccess else {
            throw KeychainError.failedToSave
        }
    }
    
    /// Carga un string del Keychain
    /// - Parameter key: Clave del dato a cargar
    /// - Returns: String guardado o nil si no existe
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let result = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return result
    }
    
    /// Elimina un elemento del Keychain
    /// - Parameter key: Clave del dato a eliminar
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}