import Foundation

// Implementación del repositorio que se encarga de la autenticación.
// Abstrae el origen de los datos (network, keychain) para que el resto de la app no sepa de dónde vienen.
final class DefaultLoginRepository: LoginRepositoryProtocol {
    
    // MARK: - Dependencias
    // El repositorio tiene dos fuentes de datos: la red y el Keychain.
    private let networkLogin: NetworkLoginProtocol
    private let keychain: kcPersistenceKeyChain
    
    init(
        networkLogin: NetworkLoginProtocol = NetworkLogin(),
        keychain: kcPersistenceKeyChain = .shared
    ) {
        self.networkLogin = networkLogin
        self.keychain = keychain
    }
    
    // MARK: - Funciones del Protocolo
    
    func signIn(email: String, password: String) async throws -> UserModel {
        do {
            // 1. Llama al servicio de red que devuelve DTOs
            let userDTO = try await networkLogin.signIn(email: email, password: password)
            // 2. Convierte DTO a Model usando el mapper
            guard let user = UserMapper.toModel(from: userDTO) else {
                throw DomainError.mappingFailed("No se pudo convertir UserDTO a UserModel")
            }
            // 3. Si tiene éxito, guarda los datos del usuario en el Keychain para persistir la sesión.
            try saveUserToKeychain(user)
            // 4. Notifica al resto de la app (aunque esto podría estar solo en el UseCase).
            NotificationCenter.default.postUserDidSignIn(user: user)
            return user
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch let domainError as DomainError {
            throw domainError
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    func signUp(email: String, password: String) async throws -> UserModel {
        do {
            // 1. Llama al servicio de red que devuelve DTOs
            let userDTO = try await networkLogin.signUp(email: email, password: password, name: extractNameFromEmail(email))
            // 2. Convierte DTO a Model usando el mapper
            guard let user = UserMapper.toModel(from: userDTO) else {
                throw DomainError.mappingFailed("No se pudo convertir UserDTO a UserModel")
            }
            // 3. Guarda y notifica
            try saveUserToKeychain(user)
            NotificationCenter.default.postUserDidSignIn(user: user)
            return user
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch let domainError as DomainError {
            throw domainError
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    func signOut() async throws {
        do {
            try await networkLogin.signOut()
            // Al cerrar sesión, es crucial borrar los datos del Keychain.
            try clearUserFromKeychain()
            NotificationCenter.default.postUserDidSignOut()
        } catch let networkError as NetworkError {
            // Incluso si la llamada de red falla, intentamos limpiar el keychain.
            try? clearUserFromKeychain()
            throw AuthError.networkError(networkError)
        } catch {
            try? clearUserFromKeychain()
            throw AuthError.signOutFailed
        }
    }
    
    // Intenta recuperar al usuario actual directamente desde el Keychain.
    func getCurrentUser() -> UserModel? {
        guard let userId = keychain.getString(key: ConstantsApp.Keychain.currentUserId),
              let userEmail = keychain.getString(key: ConstantsApp.Keychain.userEmail),
              let userData = keychain.get(key: "user_data_\(userId)"),
              let userName = String(data: userData, encoding: .utf8) else {
            return nil
        }
        
        return UserModel(id: userId, email: userEmail, displayName: userName)
    }
    
    func refreshToken() async throws -> String {
        do {
            let newToken = try await networkLogin.refreshToken()
            // Guarda el nuevo token en el keychain para mantener la sesión activa.
            try keychain.saveString(key: ConstantsApp.Keychain.userToken, value: newToken)
            return newToken
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch {
            throw AuthError.tokenExpired
        }
    }
    
    func isUserAuthenticated() -> Bool {
        return getCurrentUser() != nil
    }
    
    func getUserToken() -> String? {
        return keychain.getString(key: ConstantsApp.Keychain.userToken)
    }
    
    // MARK: - Métodos Privados
    
    // Guarda toda la información del usuario en el Keychain de forma segura.
    private func saveUserToKeychain(_ user: UserModel) throws {
        try keychain.saveString(key: ConstantsApp.Keychain.currentUserId, value: user.id)
        try keychain.saveString(key: ConstantsApp.Keychain.userEmail, value: user.email)
        
        let userDataKey = "user_data_\(user.id)"
        try keychain.saveString(key: userDataKey, value: user.name)
        
        let mockToken = "mock-jwt-token-\(UUID().uuidString)"
        try keychain.saveString(key: ConstantsApp.Keychain.userToken, value: mockToken)
    }
    
    // Limpia todos los datos de la sesión del Keychain.
    private func clearUserFromKeychain() throws {
        let userId = keychain.getString(key: ConstantsApp.Keychain.currentUserId)
        
        try keychain.delete(key: ConstantsApp.Keychain.currentUserId)
        try keychain.delete(key: ConstantsApp.Keychain.userEmail)
        try keychain.delete(key: ConstantsApp.Keychain.userToken)
        
        if let userId = userId {
            try keychain.delete(key: "user_data_\(userId)")
        }
    }
    
    // Pequeña utilidad para generar un nombre a partir del email.
    private func extractNameFromEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        if let firstComponent = components.first, !firstComponent.isEmpty {
            return firstComponent.capitalized
        }
        return "Usuario"
    }
}