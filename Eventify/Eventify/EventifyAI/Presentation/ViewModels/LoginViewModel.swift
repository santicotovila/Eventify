//
//  LoginViewModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 9/9/25.
//

import Foundation


@Observable
final class LoginViewModel {
    
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
   
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    private let loginUseCase: LoginUseCaseProtocol
    
    // Inyectamos el caso de uso para poder testearlo fácilmente (con un mock).
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    // Se llama desde la vista cuando el usuario pulsa el boton de login.
    @MainActor
    func signIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await loginUseCase.signIn(email: email, password: password)
        } catch {
            errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
