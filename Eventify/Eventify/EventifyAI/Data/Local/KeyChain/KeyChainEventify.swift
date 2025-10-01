//
//  KeyChainEventify.swift
//  EventifyAI
//
//  Created by Javier Gómez on 16/9/25.
//

import Foundation
import Security

// Singleton para manejar Keychain - almacenamiento seguro de datos sensibles
final class KeyChainEventify {
    
    static let shared = KeyChainEventify()  // Patrón Singleton
    
    private let serviceIdentifier = "com.eventifyai.keychain"
    
    private init() {}  // Private init para singleton
    
    // Guardar usuario completo en Keychain
    func saveCurrentUser(_ user: UserModel) throws {
        // Guardar datos individuales
        try saveString(key: ConstantsApp.Keychain.currentUserId, value: user.id)
        try saveString(key: ConstantsApp.Keychain.userEmail, value: user.email)
        
        // Guardar objeto completo como JSON
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
    }
    
    // Recuperar usuario guardado
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
            return nil
        }
    }
    
    // Limpiar todos los datos del usuario
    func clearCurrentUser() throws {
        try delete(key: ConstantsApp.Keychain.currentUserId)
        try delete(key: ConstantsApp.Keychain.userEmail)
        try delete(key: ConstantsApp.Keychain.userToken)
        try delete(key: "user_complete_data")
    }
    
    // Métodos para tokens JWT - sesión del usuario
    func saveUserToken(_ token: String) throws {
        try saveString(key: ConstantsApp.Keychain.userToken, value: token)
    }
    
    func getUserToken() -> String? {
        return getString(key: ConstantsApp.Keychain.userToken)
    }
    
    func clearUserToken() throws {
        try delete(key: ConstantsApp.Keychain.userToken)
    }
    
    // Configuraciones generales de la app - uso de generics para cualquier tipo
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
            return nil
        }
    }
    
    // MARK: - Métodos privados para Keychain usando Security Framework
    
    // Guardar datos binarios en Keychain
    func save(key: String, data: Data) throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ] as [String: Any]
        
        // Eliminar elemento existente antes de guardar
        SecItemDelete(query as CFDictionary)
        
        // Crear nuevo elemento en Keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyChainEventifyError.unableToSave(status)
        }
    }
    
    // Guardar String convirtiendo a Data
    func saveString(key: String, value: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeyChainEventifyError.invalidData
        }
        try save(key: key, data: data)
    }
    
    // Recuperar datos de Keychain
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
    
    // Recuperar String desde Data
    func getString(key: String) -> String? {
        guard let data = get(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    // Eliminar elemento específico
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
    
    // Limpiar todos los datos de esta app
    func clearAll() throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceIdentifier
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyChainEventifyError.unableToDelete(status)
        }
    }
    
    // Verificar si existe una clave
    func exists(key: String) -> Bool {
        return get(key: key) != nil
    }
    
    // Obtener todas las claves guardadas (útil para debug)
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


// MARK: - Modelos auxiliares

// Estructura para datos de usuario en Keychain - solo datos necesarios
private struct UserKeychainData: Codable {
    let id: String
    let email: String
    let name: String
    let lastLoginDate: Date
}

// Errores específicos de Keychain con códigos de Security Framework
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

// MARK: - Extensions para funcionalidades específicas

extension KeyChainEventify {
    
    // Configuraciones de usuario específicas
    func saveUserSettings(_ settings: UserSettings) throws {
        try saveAppSetting(key: "user_settings", value: settings)
    }
    
    func getUserSettings() -> UserSettings? {
        return getAppSetting(key: "user_settings", type: UserSettings.self)
    }
}

// MARK: - Modelo de configuraciones de usuario

struct UserSettings: Codable {
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var language: String
    var autoSyncEnabled: Bool
    
    // Valores por defecto para la app
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
