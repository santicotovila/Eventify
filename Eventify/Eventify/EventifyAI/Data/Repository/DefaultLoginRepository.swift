import Foundation

// Implementación del repositorio que se encarga de la autenticación.
// Abstrae el origen de los datos (network, keychain) para que el resto de la app no sepa de dónde vienen.
final class DefaultLoginRepository: LoginRepositoryProtocol {
    
    // MARK: - Dependencias
    // El repositorio tiene dos fuentes de datos: la red y el Keychain.
    private let networkLogin: NetworkLoginProtocol
    private let keychain: KeyChainEventify
    
    init(
        networkLogin: NetworkLoginProtocol = NetworkLogin(),
        keychain: KeyChainEventify = .shared
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
            try keychain.saveCurrentUser(user)
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
            try keychain.saveCurrentUser(user)
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
            try keychain.clearCurrentUser()
            // Notifica al resto de la app que el usuario ha cerrado sesión.
            NotificationCenter.default.postUserDidSignOut()
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    func getCurrentUser() -> UserModel? {
        return keychain.getCurrentUser()
    }
    
    func isUserAuthenticated() -> Bool {
        return getCurrentUser() != nil
    }
    
    func getUserToken() -> String? {
        return keychain.getUserToken()
    }
    
    func refreshToken() async throws -> String {
        do {
            let newToken = try await networkLogin.refreshToken()
            try keychain.saveUserToken(newToken)
            return newToken
        } catch let networkError as NetworkError {
            throw AuthError.networkError(networkError)
        } catch {
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Métodos Privados
    
    private func extractNameFromEmail(_ email: String) -> String {
        let components = email.components(separatedBy: "@")
        return components.first?.capitalized ?? "Usuario"
    }
}