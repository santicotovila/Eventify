import Foundation

// Esta clase maneja el login y registro
// @MainActor hace que todo funcione en el hilo principal para la UI
@MainActor
final class LoginViewModel: ObservableObject {
    
    // Variables que la pantalla puede ver y cambiar
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSignUp: Bool = false
    @Published var loginState: LoadingState<User> = .idle
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // Cosas que necesita para funcionar
    private let authUseCase: AuthUseCaseProtocol
    private let onUserSignedIn: (User) -> Void
    
    // Variables calculadas
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }
    
    var actionButtonTitle: String {
        isSignUp ? "Registrarse" : "Iniciar Sesión"
    }
    
    var toggleButtonTitle: String {
        isSignUp ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate"
    }
    
    // Constructor
    init(authUseCase: AuthUseCaseProtocol, onUserSignedIn: @escaping (User) -> Void) {
        self.authUseCase = authUseCase
        self.onUserSignedIn = onUserSignedIn
        
        // Revisar si ya hay alguien logueado
        checkExistingSession()
    }
    
    // Métodos que usa la pantalla
    
    // Hace login o registro dependiendo de lo que el usuario quiera
    func authenticate() async {
        guard isFormValid else {
            showError("Por favor completa todos los campos")
            return
        }
        
        loginState = .loading
        
        do {
            let user: User
            
            if isSignUp {
                user = try await authUseCase.signUp(email: email.trimmingCharacters(in: .whitespacesAndNewlines), 
                                                  password: password)
            } else {
                user = try await authUseCase.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), 
                                                  password: password)
            }
            
            loginState = .success(user)
            clearForm()
            
            // Avisar que el usuario ya se logueo
            onUserSignedIn(user)
            
        } catch {
            loginState = .failure(error)
            showError(error.localizedDescription)
        }
    }
    
    // Cambia entre login y registro
    func toggleAuthMode() {
        isSignUp.toggle()
        clearErrors()
    }
    
    // Revisa si ya hay alguien logueado
    func checkExistingSession() {
        if let user = authUseCase.getCurrentUser() {
            loginState = .success(user)
        }
    }
    
    // Métodos internos
    
    // Muestra un error en pantalla
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    // Borra el formulario después de loguearse
    private func clearForm() {
        email = ""
        password = ""
    }
    
    // Quita los mensajes de error
    private func clearErrors() {
        showAlert = false
        alertMessage = ""
        if case .failure = loginState {
            loginState = .idle
        }
    }
    
}