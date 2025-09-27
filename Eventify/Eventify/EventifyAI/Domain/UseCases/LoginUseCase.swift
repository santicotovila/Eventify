//
//  LoginUseCase.swift
//  EventifyAI
//
//  Created by Javier Gómez on 8/9/25.
//

import Foundation
// Usar un protocolo facilita los tests y desacopla el código.
protocol LoginUseCaseProtocol {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String) async throws -> UserModel
    func signOut() async throws
    func getCurrentUser() -> UserModel?
    func isUserAuthenticated() -> Bool
    func refreshToken() async throws -> String
    func saveUser(_ user: UserModel) throws
}

// Contiene la lógica de negocio pura para la autenticación.
// Orquesta la validación, el repositorio y las notificaciones.
final class LoginUseCase: LoginUseCaseProtocol {
    
    // MARK: - Dependencias
    // Dependemos de un protocolo, no de una clase concreta. Esto es Inversión de Dependencias.
    private let loginRepository: LoginRepositoryProtocol
    
    init(loginRepository: LoginRepositoryProtocol) {
        self.loginRepository = loginRepository
    }
    
    // MARK: - Funciones Públicas
    
    func signIn(email: String, password: String) async throws -> UserModel {
        // Regla de negocio: validar datos antes de continuar.
        try validateSignInData(email: email, password: password)
        
        do {
            // Pide al repositorio que autentique al usuario.
            let user = try await loginRepository.signIn(email: email, password: password)
            
            // Avisa al resto de la app que el login fue exitoso.
            await MainActor.run {
                NotificationCenter.default.postUserDidSignIn(user: user)
            }
            
            return user
        } catch {
            // Envolvemos el error en uno propio del caso de uso para dar más contexto.
            throw LoginUseCaseError.signInFailed(error)
        }
    }
    
    func signUp(email: String, password: String) async throws -> UserModel {
        try validateSignUpData(email: email, password: password)
        
        do {
            let user = try await loginRepository.signUp(email: email, password: password)
            
            // Al registrarse, también se inicia sesión.
            await MainActor.run {
                NotificationCenter.default.postUserDidSignIn(user: user)
            }
            
            return user
        } catch {
            throw LoginUseCaseError.signUpFailed(error)
        }
    }
    
    func signOut() async throws {
        guard getCurrentUser() != nil else {
            throw LoginUseCaseError.userNotAuthenticated
        }
        
        do {
            try await loginRepository.signOut()
            // Avisa a la app que el usuario ha cerrado sesión.
            await MainActor.run {
                NotificationCenter.default.postUserDidSignOut()
            }
        } catch {
            throw LoginUseCaseError.signOutFailed(error)
        }
    }
    
    func getCurrentUser() -> UserModel? {
        return loginRepository.getCurrentUser()
    }
    
    func isUserAuthenticated() -> Bool {
        return getCurrentUser() != nil
    }
    
    func refreshToken() async throws -> String {
        guard getCurrentUser() != nil else {
            throw LoginUseCaseError.userNotAuthenticated
        }
        
        do {
            if let defaultRepository = loginRepository as? DefaultLoginRepository {
                return try await defaultRepository.refreshToken()
            }
            
            return "mock-refreshed-token-\(UUID().uuidString)"
        } catch {
            throw LoginUseCaseError.tokenRefreshFailed(error)
        }
    }
    
    // MARK: - Métodos Privados de Validación
    
    private func validateSignInData(email: String, password: String) throws {
        guard !email.isEmpty else { throw LoginUseCaseError.emptyEmail }
        guard isValidEmail(email) else { throw LoginUseCaseError.invalidEmailFormat }
        guard !password.isEmpty else { throw LoginUseCaseError.emptyPassword }
        guard password.count >= ConstantsApp.Validation.minPasswordLength else { throw LoginUseCaseError.passwordTooShort }
    }
    
    private func validateSignUpData(email: String, password: String) throws {
        try validateSignInData(email: email, password: password)
        guard password.count <= 50 else { throw LoginUseCaseError.passwordTooLong }
        guard isStrongPassword(password) else { throw LoginUseCaseError.weakPassword }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isStrongPassword(_ password: String) -> Bool {
        // En una app real, aquí habría una lógica más compleja (mayúsculas, números, etc.)
        return password.count >= ConstantsApp.Validation.minPasswordLength
    }
    
    func saveUser(_ user: UserModel) throws {
        try loginRepository.saveUser(user)
    }
}

// Errores específicos de este caso de uso para no exponer detalles de capas inferiores.
enum LoginUseCaseError: Error, LocalizedError {
    case emptyEmail
    case emptyPassword
    case invalidEmailFormat
    case passwordTooShort
    case passwordTooLong
    case weakPassword
    case userNotAuthenticated
    case sessionExpired
    case signInFailed(Error)
    case signUpFailed(Error)
    case signOutFailed(Error)
    case tokenRefreshFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail: return "El email es requerido"
        case .emptyPassword: return "La contraseña es requerida"
        case .invalidEmailFormat: return "Formato de email inválido"
        case .passwordTooShort: return "La contraseña debe tener al menos \(ConstantsApp.Validation.minPasswordLength) caracteres"
        case .passwordTooLong: return "La contraseña no puede exceder 50 caracteres"
        case .weakPassword: return "La contraseña debe ser más segura"
        case .userNotAuthenticated: return "Usuario no autenticado"
        case .sessionExpired: return "Sesión expirada. Por favor, inicia sesión nuevamente"
        case .signInFailed(let error): return "Error al iniciar sesión: \(error.localizedDescription)"
        case .signUpFailed(let error): return "Error al registrarse: \(error.localizedDescription)"
        case .signOutFailed(let error): return "Error al cerrar sesión: \(error.localizedDescription)"
        case .tokenRefreshFailed(let error): return "Error al renovar sesión: \(error.localizedDescription)"
        }
    }
}
