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
        // Creamos el ViewModel pasándole el caso de uso que necesita, que obtenemos de nuestra AppFactory.
        self._viewModel = StateObject(wrappedValue: LoginViewModel(
            loginUseCase: AppFactory.shared.makeLoginUseCase()
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
                    Image(systemName: "calendar.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("EventifyAI")
                        .font(.largeTitle).fontWeight(.bold).foregroundColor(.white)
                    
                    Text("Organiza eventos inteligentes")
                        .font(.title3).foregroundColor(.white.opacity(0.8))
                }
                
                // Formulario de login.
                VStack(spacing: 20) {
                    // El `$` en `$viewModel.email` crea un "binding" (un enlace de dos vías).
                    // Si el usuario escribe en el TextField, la propiedad `email` del ViewModel se actualiza.
                    // Si cambiamos la propiedad `email` en el ViewModel, el texto del TextField cambiará.
                    TextField("tu@email.com", text: $viewModel.email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("••••••••", text: $viewModel.password)
                        .textFieldStyle(CustomTextFieldStyle())
                    
                    // Botón de acción principal.
                    Button(action: {
                        // La acción del botón es simple: llamar a la función correspondiente del ViewModel.
                        Task { await viewModel.signIn() }
                    }) {
                        // El contenido del botón cambia si está en estado de carga.
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        } else {
                            Text("Iniciar Sesión").fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    // El botón se deshabilita si el formulario no es válido o si ya está cargando.
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
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
