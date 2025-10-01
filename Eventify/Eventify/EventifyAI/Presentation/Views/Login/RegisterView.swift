import SwiftUI

// Vista de registro - primera parte del proceso de registro
struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppStateVM.self) var appState: AppStateVM
    // @State para campos del formulario - datos locales de la vista
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showContinueRegistration = false
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 0) {
                // Header con botón de retroceso
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                VStack(spacing: 32) {
                    // Header con placeholder de foto de perfil
                    VStack(spacing: 16) {
                    // Placeholder para foto de perfil (funcionalidad pendiente)
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                        
                        VStack(spacing: 8) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 30))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Añadir foto\nde perfil")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                // Formulario de registro
                VStack(spacing: 20) {
                    // Campo de nombre de usuario
                    HStack {
                        Image(systemName: "person")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        TextField("Nombre de usuario", text: $username)
                            .autocapitalization(.none)
                            .submitLabel(.next)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Campo de email
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .submitLabel(.next)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Campo de contraseña
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        SecureField("Contraseña", text: $password)
                            .submitLabel(.next)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Campo de repetir contraseña
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        SecureField("Repetir Contraseña", text: $confirmPassword)
                            .submitLabel(.go)
                        
                        // Validación visual en tiempo real
                        if !confirmPassword.isEmpty && password != confirmPassword {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        } else if !confirmPassword.isEmpty && password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(15)
                    
                    // Texto de campos obligatorios y requisitos
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("* Contraseña mínimo 8 caracteres")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                        
                    }
                    
                    // Botón continuar
                    Button(action: {
                        showContinueRegistration = true
                    }) {
                        Text("Continuar")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .disabled(!isFormValid)
                    
                    // Separador
                    Text("continuar con")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                        .padding(.top)
                    
                    // Opciones sociales (solo imágenes como solicitaste)
                    HStack(spacing: 20) {
                        // Google
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text("G")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            )
                        
                        // Apple
                        Circle()
                            .fill(Color.white)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "apple.logo")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            )
                        
                        // X (Twitter)
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
                .padding(.horizontal, 32)
                
                    Spacer()
                }
                .padding()
            }
        }
        // Modal para segunda parte del registro (selección de intereses)
        .fullScreenCover(isPresented: $showContinueRegistration) {
            ContinueRegistrationView(
                userName: username,
                email: email,
                password: password,
                loginUseCase: appState.loginUseCase
            )
        }
    }
    
    // Computed property para validación del formulario
    private var isFormValid: Bool {
        return !username.isEmpty && 
               !email.isEmpty && 
               !password.isEmpty && 
               !confirmPassword.isEmpty &&
               password.count >= 6 &&
               email.contains("@") &&
               password == confirmPassword
    }
}

#Preview {
    let loginRepository = DefaultLoginRepository()
    let loginUseCase = LoginUseCase(loginRepository: loginRepository)
    let appState = AppStateVM(loginUseCase: loginUseCase)
    return RegisterView()
        .environment(appState)
}
