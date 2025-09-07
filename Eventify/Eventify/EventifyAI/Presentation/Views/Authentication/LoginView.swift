import SwiftUI

// Esta es la pantalla de login y registro
struct LoginView: View {
    
    // Variables que necesita
    @StateObject private var viewModel: LoginViewModel
    
    // Constructor
    init(onUserSignedIn: @escaping (User) -> Void) {
        self._viewModel = StateObject(wrappedValue: LoginViewModel(
            authUseCase: AppFactory.shared.makeAuthUseCase(),
            onUserSignedIn: onUserSignedIn
        ))
    }
    
    // Lo que se ve en la pantalla
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo con degradado
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Título de arriba
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("EventifyAI")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Organiza eventos inteligentes")
                            .font(.subtitle)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Formulario
                    VStack(spacing: 20) {
                        // Campo de email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("tu@email.com", text: $viewModel.email)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contraseña")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            SecureField("••••••••", text: $viewModel.password)
                                .textFieldStyle(CustomTextFieldStyle())
                                .textContentType(viewModel.isSignUp ? .newPassword : .password)
                        }
                        
                        // Action Button
                        Button(action: {
                            Task {
                                await viewModel.authenticate()
                            }
                        }) {
                            HStack {
                                if viewModel.loginState.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                        .scaleEffect(0.8)
                                }
                                
                                Text(viewModel.actionButtonTitle)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(25)
                            .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                        }
                        .disabled(!viewModel.isFormValid || viewModel.loginState.isLoading)
                        
                        // Toggle Mode Button
                        Button(action: {
                            viewModel.toggleAuthMode()
                        }) {
                            Text(viewModel.toggleButtonTitle)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .disabled(viewModel.loginState.isLoading)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}

/// Estilo personalizado para campos de texto
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .font(.body)
    }
}

#Preview {
    LoginView(onUserSignedIn: { _ in })
}

// MARK: - Mock para Preview
final class MockAuthUseCase: AuthUseCaseProtocol {
    func signIn(email: String, password: String) async throws -> User {
        return User(id: "preview", email: email)
    }
    
    func signUp(email: String, password: String) async throws -> User {
        return User(id: "preview", email: email)
    }
    
    func signOut() async throws {}
    
    func getCurrentUser() -> User? {
        return nil
    }
    
    func isUserSignedIn() -> Bool {
        return false
    }
}