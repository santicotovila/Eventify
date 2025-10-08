
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
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }

    @MainActor  // Asegura que se ejecute en el hilo principal
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
