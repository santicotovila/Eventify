import Foundation
import Combine

// Gestiona el estado global de la app (si el usuario está logueado o no).
// Se comparte por toda la app como un EnvironmentObject para que cualquier vista pueda acceder a él.
@MainActor
final class AppStateVM: ObservableObject {
    
    // MARK: - Propiedades de Estado Global
    @Published var isUserAuthenticated: Bool = false
    @Published var currentUser: UserModel?
    @Published var selectedTab: Int = 0
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    // MARK: - Dependencias y Suscripciones
    private let loginUseCase: LoginUseCaseProtocol
    // Guardamos aquí las suscripciones de Combine para que no "mueran".
    private var cancellables = Set<AnyCancellable>()
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
        // Al iniciar, comprobamos si ya hay una sesión guardada.
        self.isUserAuthenticated = loginUseCase.isUserAuthenticated()
        self.currentUser = loginUseCase.getCurrentUser()
        setupSubscribers()
    }
    
    // Comprueba de nuevo el estado de autenticación.
    func checkAuthenticationState() {
        self.isUserAuthenticated = loginUseCase.isUserAuthenticated()
        self.currentUser = loginUseCase.getCurrentUser()
    }
    
    // Métodos para manejar alertas
    func showAlert(message: String) {
        self.alertMessage = message
        self.showAlert = true
    }
    
    func dismissAlert() {
        self.showAlert = false
        self.alertMessage = ""
    }
    
    // Propiedad computada para el nombre de usuario
    var userDisplayName: String {
        return currentUser?.displayName ?? "Usuario"
    }
    
    // Estado de carga
    @Published var isLoading: Bool = false
    
    // Método para cerrar sesión
    func signOut() async {
        isLoading = true
        
        do {
            try await loginUseCase.signOut()
            // El estado se actualiza automáticamente por las notificaciones
        } catch {
            showAlert(message: "Error al cerrar sesión: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Suscripciones a Notificaciones
    // Escucha notificaciones globales para mantener el estado actualizado.
    private func setupSubscribers() {
        // Se suscribe a la notificación de login exitoso.
        NotificationCenter.default.userDidSignInPublisher
            .receive(on: DispatchQueue.main) // Actualiza en el hilo principal.
            .sink { [weak self] user in // Cuando llega la notificación, ejecuta esto.
                self?.isUserAuthenticated = true
                self?.currentUser = user
            }
            .store(in: &cancellables) // Guarda la suscripción para mantenerla viva.
        
        // Se suscribe a la notificación de logout.
        NotificationCenter.default.userDidSignOutPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_: Void) in
                self?.isUserAuthenticated = false
                self?.currentUser = nil
            }
            .store(in: &cancellables)
    }
}
