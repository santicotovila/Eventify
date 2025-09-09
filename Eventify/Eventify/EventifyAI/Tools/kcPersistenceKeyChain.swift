import Foundation
import Security

final class kcPersistenceKeyChain {
    
    static let shared = kcPersistenceKeyChain()
    
    private init() {}
    
    // MARK: - Save Methods
    
    func save(key: String, data: Data) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw kcKeychainError.unableToSave
        }
    }
    
    func saveString(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw kcKeychainError.invalidData
        }
        try save(key: key, data: data)
    }
    
    // MARK: - Get Methods
    
    func get(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    func getString(key: String) -> String? {
        guard let data = get(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // MARK: - Delete Methods
    
    func delete(key: String) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw kcKeychainError.unableToDelete
        }
    }
    
    // MARK: - Clear All
    
    func clearAll() throws {
        let query = [kSecClass as String: kSecClassGenericPassword] as [String: Any]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw kcKeychainError.unableToDelete
        }
    }
}

// MARK: - Keychain Errors

enum kcKeychainError: Error {
    case invalidData
    case unableToSave
    case unableToDelete
    
    var localizedDescription: String {
        switch self {
        case .invalidData:
            return "Los datos proporcionados no son válidos"
        case .unableToSave:
            return "No se pudo guardar en Keychain"
        case .unableToDelete:
            return "No se pudo eliminar de Keychain"
        }
    }
}