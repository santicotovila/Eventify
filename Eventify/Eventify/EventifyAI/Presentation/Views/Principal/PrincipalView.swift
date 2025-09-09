import SwiftUI

struct PrincipalView: View {
    
    @State private var appStateVM: AppStateVM
    
    init() {
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        self._appStateVM = State(wrappedValue: AppStateVM(loginUseCase: loginUseCase))
    }
    
    var body: some View {
        TabView(selection: $appStateVM.selectedTab) {
            EventsView()
            .tabItem {
                Image(systemName: "calendar")
                Text("Eventos")
            }
            .tag(0)
            
            ProfileView(appStateVM: appStateVM)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Perfil")
                }
                .tag(1)
        }
        .accentColor(.blue)
        .alert("Notificación", isPresented: $appStateVM.showAlert) {
            Button("OK") {
                appStateVM.dismissAlert()
            }
        } message: {
            Text(appStateVM.alertMessage)
        }
    }
}

struct ProfileView: View {
    let appStateVM: AppStateVM
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // User Info Section
                VStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text(appStateVM.userDisplayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let email = appStateVM.currentUser?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // Options Section
                VStack(spacing: 16) {
                    ProfileOptionRow(
                        icon: "gear",
                        title: "Configuración",
                        action: {
                            // TODO: Navigate to settings
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "questionmark.circle",
                        title: "Ayuda y Soporte",
                        action: {
                            // TODO: Navigate to help
                        }
                    )
                    
                    ProfileOptionRow(
                        icon: "info.circle",
                        title: "Acerca de",
                        action: {
                            // TODO: Navigate to about
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Sign Out Button
                Button {
                    Task {
                        await appStateVM.signOut()
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar Sesión")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(appStateVM.isLoading)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Perfil")
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    PrincipalView()
}