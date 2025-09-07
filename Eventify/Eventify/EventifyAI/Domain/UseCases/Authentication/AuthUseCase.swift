import Foundation

// Define qué cosas puede hacer el login
protocol AuthUseCaseProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() -> User?
    func isUserSignedIn() -> Bool
}

// Esta clase maneja todo lo del login y registro
class AuthUseCase: AuthUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    private let keychainManager: KeychainManagerProtocol
    
    init(authRepository: AuthRepositoryProtocol, keychainManager: KeychainManagerProtocol) {
        self.authRepository = authRepository
        self.keychainManager = keychainManager
    }
    
    // Hace login del usuario
    func signIn(email: String, password: String) async throws -> User {
        // Revisar que el email tenga formato correcto
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        // Revisar que la contraseña no esté vacía
        guard !password.isEmpty else {
            throw AuthError.invalidPassword
        }
        
        let user = try await authRepository.signIn(email: email, password: password)
        
        // Guardar el email del usuario de forma segura
        try keychainManager.save(key: "user_email", data: email)
        
        return user
    }
    
    // Registra un usuario nuevo
    func signUp(email: String, password: String) async throws -> User {
        // Revisar que el email tenga formato correcto
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }
        
        // Revisar que la contraseña sea lo suficientemente fuerte
        guard isValidPassword(password) else {
            throw AuthError.weakPassword
        }
        
        let user = try await authRepository.signUp(email: email, password: password)
        
        // Guardar el email del usuario nuevo de forma segura
        try keychainManager.save(key: "user_email", data: email)
        
        return user
    }
    
    // Cierra la sesión del usuario
    func signOut() async throws {
        try await authRepository.signOut()
        
        // Borra la info guardada del usuario
        keychainManager.delete(key: "user_email")
    }
    
    // Obtiene el usuario que está logueado ahora
    func getCurrentUser() -> User? {
        return authRepository.getCurrentUser()
    }
    
    // Revisa si hay alguien logueado
    func isUserSignedIn() -> Bool {
        return authRepository.getCurrentUser() != nil
    }
    
    // Métodos privados (solo para uso interno)
    
    // Revisa si el email tiene formato válido
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // Revisa que la contraseña tenga al menos 6 letras
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}