import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @Environment(AppStateVM.self) var appState: AppStateVM
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self._viewModel = State(wrappedValue: ProfileViewModel(loginUseCase: loginUseCase))
    }
    
    var body: some View {
        ZStack {
            // Fondo con gradiente exacto
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
                // Header - exacto como Figma
                HStack {
                    Text("Perfil")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Tarjeta blanca exacta como Figma
                VStack(spacing: 0) {
                    // Avatar circular en la parte superior
                    Circle()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.clear)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.3), .blue.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            // Simulando foto de perfil como en Figma
                            Circle()
                                .fill(Color.purple.opacity(0.7))
                                .overlay(
                                    Text(viewModel.userInitials)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        )
                        .padding(.top, 32)
                    
                    // Información del usuario exacta como Figma
                    VStack(spacing: 12) {
                        // Nombre
                        Text(viewModel.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 20)
                        
                        // Email
                        if let user = viewModel.currentUser {
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Información adicional exacta como Figma
                        VStack(spacing: 8) {
                            Text(viewModel.phoneNumber)
                                .font(.body)
                                .foregroundColor(.black)
                            
                            Text("Jaén")
                                .font(.body)
                                .foregroundColor(.black)
                            
                            Text(viewModel.formattedBirthDate)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 16)
                    }
                    
                    Spacer()
                }
                .frame(width: 328, height: 368)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple, lineWidth: 4)
                )
                
                // Botón "Modificar datos personales" exacto como Figma
                Button(action: {
                    viewModel.showEditProfile()
                }) {
                    Text("Modificar datos personales")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 295, height: 50)
                        .background(Color.purple.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Botón "Cerrar sesión" exacto como Figma
                Button(action: {
                    viewModel.showLogoutConfirmation()
                }) {
                    HStack(spacing: 8) {
                        Text("Cerrar sesión")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "power")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $viewModel.showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .alert("Cerrar Sesión", isPresented: $viewModel.showingLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                Task {
                    await viewModel.signOut()
                }
            }
        } message: {
            Text("¿Estás seguro que quieres cerrar sesión?")
        }
    }
}

// MARK: - Edit Profile View (simplificada)

struct EditProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Información Personal") {
                    TextField("Nombre", text: $viewModel.displayName)
                    TextField("Teléfono", text: $viewModel.phoneNumber)
                    DatePicker("Fecha de Nacimiento", selection: $viewModel.birthDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        Task {
                            await viewModel.saveProfile()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    let loginRepository = DefaultLoginRepository()
    let loginUseCase = LoginUseCase(loginRepository: loginRepository)
    let appState = AppStateVM(loginUseCase: loginUseCase)
    
    ProfileView(loginUseCase: loginUseCase)
        .environment(appState)
}