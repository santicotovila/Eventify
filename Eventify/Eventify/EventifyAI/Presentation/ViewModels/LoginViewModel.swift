import Foundation

// El cerebro de la LoginView. Conecta la UI con la lógica de negocio.
@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - Propiedades para la Vista
    // @Published avisa a la vista cuando estos valores cambian para que se redibuje.
    @Published var email: String = ""
    @Published var password: String = ""
    
    // Propiedades para controlar el estado de la UI (loader, errores...)
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Propiedades Computadas
    var isFormValid: Bool {
        return !email.isEmpty && !password.isEmpty
    }
    
    // MARK: - Dependencias
    private let loginUseCase: LoginUseCaseProtocol
    
    // Inyectamos el caso de uso para poder testearlo fácilmente (con un mock).
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }
    
    // MARK: - Acciones
    // Se llama desde la vista cuando el usuario pulsa el botón de login.
    func signIn() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // El ViewModel no hace la lógica, se la pide al UseCase.
            _ = try await loginUseCase.signIn(email: email, password: password)
            // El estado global de la app se actualiza por notificaciones, no aquí directamente.
        } catch {
            errorMessage = "Error al iniciar sesión: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
