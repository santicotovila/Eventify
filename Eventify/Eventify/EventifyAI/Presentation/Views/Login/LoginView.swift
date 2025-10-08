
import SwiftUI

// Vista de Login - formulario de autenticación con diseño moderno
struct LoginView: View {
    
    // @State para ViewModel local de esta vista
    @State private var viewModel: LoginViewModel
    @State private var showRegister = false
    // @Environment para estado global de la app
    @Environment(AppStateVM.self) var appState: AppStateVM
    
    // Dependency injection manual - creamos las dependencias aquí
    init() {
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        
        self._viewModel = State(wrappedValue: LoginViewModel(
            loginUseCase: loginUseCase
        ))
    }
    
    // MARK: - UI de la vista
    var body: some View {
        ZStack {
            // Fondo con gradiente - LinearGradient de SwiftUI
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.08, green: 0.31, blue: 0.6), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.31, green: 0.27, blue: 0.58), location: 0.40),
                    Gradient.Stop(color: Color(red: 0.45, green: 0.22, blue: 0.57), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.02, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header con logo de la app
                VStack(spacing: 16) {
                    // Logo circular
                    ZStack {
                        VStack(spacing: 6) {
                            Image("Logo-Eventify")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                        }
                    }
                    
                    Text("Eventify")
                        .font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                }
                
                // Formulario de entrada - campos con binding al ViewModel
                VStack(spacing: 20) {
                    // Campo email con icono SF Symbols
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        TextField("Usuario", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .submitLabel(.next)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Campo contraseña con SecureField
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        SecureField("Contraseña", text: $viewModel.password)
                            .submitLabel(.go)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Botón login con Task para async/await
                    Button(action: {
                        Task { await viewModel.signIn() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Acceder").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    
                    // Boton de registrarse
                    Button("Registrarme") {
                        showRegister = true
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.clear)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    
                    // Recuperar contraseña
                    Button("Recuperar contraseña 🔑") {
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .font(.subheadline)
                    
                    // Separador
                    Text("continuar con")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                        .padding(.top)
                    
                    // Opciones sociales
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("G")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                )
                        }
                        
                        Button(action: {}) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "apple.logo")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                )
                        }
                        
                        Button(action: {}) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text("X")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                )
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .padding()
        }
        // Alert para mostrar errores - binding con computed property
        .alert("Error de Login", isPresented: .constant(viewModel.errorMessage != nil), actions: {}) {
            Text(viewModel.errorMessage ?? "")
        }
        // Modal de registro - fullScreenCover para pantalla completa
        .fullScreenCover(isPresented: $showRegister) {
            RegisterView()
                .environment(appState)
        }
    }
}

// MARK: - Estilos personalizados para componentes

// ButtonStyle personalizado - protocolo de SwiftUI para estilos reutilizables
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .foregroundColor(.blue)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Animación al tocar
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// TextFieldStyle personalizado para campos de entrada consistentes
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .font(.body)
    }
}

// MARK: - Extensions para funcionalidad adicional

// Extension de View para placeholder personalizado usando @ViewBuilder
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview para desarrollo

#Preview {
    LoginView()
}
