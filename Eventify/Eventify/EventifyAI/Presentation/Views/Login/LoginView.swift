import SwiftUI

// La vista para el Login. En MVVM, la vista es la parte "tonta":
// solo muestra lo que el ViewModel le dice y le informa de las acciones del usuario.
struct LoginView: View {
    
    // MARK: - ViewModel
    // Usamos @StateObject porque esta vista "posee" a su ViewModel.
    // El ViewModel será la única fuente de verdad para esta pantalla.
    @StateObject private var viewModel: LoginViewModel
    
    // MARK: - Inicializador
    // Inyectamos las dependencias que necesita el ViewModel para funcionar.
    init() {
        // Creamos el ViewModel pasándole el caso de uso con inyección directa.
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        
        self._viewModel = StateObject(wrappedValue: LoginViewModel(
            loginUseCase: loginUseCase
        ))
    }
    
    // MARK: - Cuerpo de la Vista
    var body: some View {
        ZStack {
            // Fondo decorativo.
            LinearGradient(colors: [.blue.opacity(0.6), .purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Cabecera con el logo y nombre de la app.
                VStack(spacing: 16) {
                    // Logo circular como en el diseño
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                        
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.orange)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "ticket")
                                            .font(.system(size: 8))
                                            .foregroundColor(.white)
                                    )
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "qrcode")
                                            .font(.system(size: 8))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.red)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "heart")
                                            .font(.system(size: 8))
                                            .foregroundColor(.white)
                                    )
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.blue)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        Image(systemName: "calendar")
                                            .font(.system(size: 8))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                    
                    Text("Eventify")
                        .font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                }
                
                // Formulario de login.
                VStack(spacing: 20) {
                    // Campo de usuario con icono
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        TextField("Usuario", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Campo de contraseña con icono
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        SecureField("Contraseña", text: $viewModel.password)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Botón de acceder
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
                    
                    // Botón de registrarse
                    Button("Registrarme") {
                        // TODO: Navegar a registro
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
                        // TODO: Implementar recuperación
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
        // La alerta se muestra solo cuando la propiedad `errorMessage` del ViewModel tiene un valor.
        .alert("Error de Login", isPresented: .constant(viewModel.errorMessage != nil), actions: {}) {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - Estilos Personalizados

// Un estilo propio para que los botones principales se vean todos iguales.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.white)
            .foregroundColor(.blue)
            .cornerRadius(25)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0) // Efecto al pulsar.
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// Estilo para los campos de texto.
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .font(.body)
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
