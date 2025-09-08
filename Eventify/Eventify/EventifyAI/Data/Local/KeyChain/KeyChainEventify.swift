import Foundation
import Security

final class KeyChainEventify {
    
    static let shared = KeyChainEventify()
    
    private let serviceIdentifier = "com.eventifyai.keychain"
    
    private init() {}
    
    // MARK: - User Authentication Methods
    
    func saveCurrentUser(_ user: UserModel) throws {
        // Guardar ID del usuario
        try saveString(key: ConstantsApp.Keychain.currentUserId, value: user.id)
        
        // Guardar email del usuario
        try saveString(key: ConstantsApp.Keychain.userEmail, value: user.email)
        
        // Guardar datos completos del usuario como JSON
        let userData = UserKeychainData(
            id: user.id,
            email: user.email,
            name: user.name,
            lastLoginDate: Date()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(userData)
        
        try save(key: "user_complete_data", data: data)
        
        print("✅ Usuario guardado en KeyChain: \(user.email)")
    }
    
    func getCurrentUser() -> UserModel? {
        guard let userData = get(key: "user_complete_data") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let keychainData = try decoder.decode(UserKeychainData.self, from: userData)
            
            return UserModel(
                id: keychainData.id,
                email: keychainData.email,
                displayName: keychainData.name
            )
        } catch {
            print("❌ Error al decodificar usuario del KeyChain: \(error)")
            return nil
        }
    }
    
    func clearCurrentUser() throws {
        try delete(key: ConstantsApp.Keychain.currentUserId)
        try delete(key: ConstantsApp.Keychain.userEmail)
        try delete(key: ConstantsApp.Keychain.userToken)
        try delete(key: "user_complete_data")
        
        print("✅ Usuario eliminado del KeyChain")
    }
    
    // MARK: - Token Methods
    
    func saveUserToken(_ token: String) throws {
        try saveString(key: ConstantsApp.Keychain.userToken, value: token)
    }
    
    func getUserToken() -> String? {
        return getString(key: ConstantsApp.Keychain.userToken)
    }
    
    func clearUserToken() throws {
        try delete(key: ConstantsApp.Keychain.userToken)
    }
    
    // MARK: - App Settings Methods
    
    func saveAppSetting<T: Codable>(key: String, value: T) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        try save(key: "setting_\(key)", data: data)
    }
    
    func getAppSetting<T: Codable>(key: String, type: T.Type) -> T? {
        guard let data = get(key: "setting_\(key)") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            print("❌ Error al decodificar configuración \(key): \(error)")
            return nil
        }
    }
    
    // MARK: - Generic Keychain Operations
    
    func save(key: String, data: Data) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]
        
        // Eliminar elemento existente
        SecItemDelete(query as CFDictionary)
        
        // Guardar nuevo elemento
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyChainEventifyError.unableToSave(status)
        }
    }
    
    func saveString(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeyChainEventifyError.invalidData
        }
        try save(key: key, data: data)
    }
    
    func get(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
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
    
    func delete(key: String) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyChainEventifyError.unableToDelete(status)
        }
    }
    
    func clearAll() throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyChainEventifyError.unableToDelete(status)
        }
        
        print("✅ KeyChain limpiado completamente")
    }
    
    // MARK: - Utility Methods
    
    func exists(key: String) -> Bool {
        return get(key: key) != nil
    }
    
    func getAllKeys() -> [String] {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecReturnAttributes as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitAll
        ] as [String: Any]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return []
        }
        
        return items.compactMap { item in
            item[kSecAttrAccount as String] as? String
        }
    }
}

// MARK: - Data Models

private struct UserKeychainData: Codable {
    let id: String
    let email: String
    let name: String
    let lastLoginDate: Date
}

// MARK: - Errors

enum KeyChainEventifyError: Error, LocalizedError {
    case invalidData
    case unableToSave(OSStatus)
    case unableToDelete(OSStatus)
    case encodingError
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Los datos proporcionados no son válidos"
        case .unableToSave(let status):
            return "No se pudo guardar en KeyChain (código: \(status))"
        case .unableToDelete(let status):
            return "No se pudo eliminar del KeyChain (código: \(status))"
        case .encodingError:
            return "Error al codificar datos"
        case .decodingError:
            return "Error al decodificar datos"
        }
    }
}

// MARK: - Extensions

extension KeyChainEventify {
    
    func saveUserSettings(_ settings: UserSettings) throws {
        try saveAppSetting(key: "user_settings", value: settings)
    }
    
    func getUserSettings() -> UserSettings? {
        return getAppSetting(key: "user_settings", type: UserSettings.self)
    }
}

// MARK: - User Settings Model

struct UserSettings: Codable {
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var language: String
    var autoSyncEnabled: Bool
    
    init(
        notificationsEnabled: Bool = true,
        darkModeEnabled: Bool = false,
        language: String = "es",
        autoSyncEnabled: Bool = true
    ) {
        self.notificationsEnabled = notificationsEnabled
        self.darkModeEnabled = darkModeEnabled
        self.language = language
        self.autoSyncEnabled = autoSyncEnabled
    }
}