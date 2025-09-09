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
            // 1. Llama al servicio de red que devuelve Models directamente
            let user = try await networkLogin.signIn(email: email, password: password)
            // 2. Si tiene éxito, guarda los datos del usuario en el Keychain para persistir la sesión.
            try saveUserToKeychain(user)
            // 3. Notifica al resto de la app (aunque esto podría estar solo en el UseCase).
            NotificationCenter.default.postUserDidSignIn(user: user)
            return user
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    func signUp(email: String, password: String) async throws -> UserModel {
        do {
            // 1. Llama al servicio de red que devuelve Models directamente
            let user = try await networkLogin.signUp(email: email, password: password, name: extractNameFromEmail(email))
            // 2. Si tiene éxito, guarda los datos del usuario en el Keychain para persistir la sesión.
            try saveUserToKeychain(user)
            // 3. Notifica al resto de la app.
            NotificationCenter.default.postUserDidSignIn(user: user)
            return user
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    func signOut() async throws {
        do {
            try await networkLogin.signOut()
            // Limpia los datos del usuario del Keychain.
            try keychain.delete(key: ConstantsApp.Keychain.currentUserId)
            try keychain.delete(key: ConstantsApp.Keychain.userEmail)
            try keychain.delete(key: ConstantsApp.Keychain.userToken)
            // Notifica al resto de la app que el usuario ha cerrado sesión.
            NotificationCenter.default.postUserDidSignOut()
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    func getCurrentUser() -> UserModel? {
        guard let userId = keychain.getString(key: ConstantsApp.Keychain.currentUserId),
              let userEmail = keychain.getString(key: ConstantsApp.Keychain.userEmail) else {
            return nil
        }
        
        return UserModel(
            id: userId,
            email: userEmail,
            displayName: extractNameFromEmail(userEmail)
        )
    }
    
    func isUserAuthenticated() -> Bool {
        return getCurrentUser() != nil
    }
    
    func getUserToken() -> String? {
        return keychain.getString(key: ConstantsApp.Keychain.userToken)
    }
    
    func refreshToken() async throws -> String {
        do {
            let newToken = try await networkLogin.refreshToken()
            try keychain.saveString(key: ConstantsApp.Keychain.userToken, value: newToken)
            return newToken
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Métodos Privados
    
    private func saveUserToKeychain(_ user: UserModel) throws {
        do {
            try keychain.saveString(key: ConstantsApp.Keychain.currentUserId, value: user.id)
            try keychain.saveString(key: ConstantsApp.Keychain.userEmail, value: user.email)
        } catch {
            throw AuthError.keychainError(error)
        }
    }
    
    private func extractNameFromEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        return components.first?.capitalized ?? "Usuario"
    }
}