import SwiftUI

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    let friendsRepository: HybridFriendsRepository
    let onFriendAdded: () -> Void
    
    @State private var searchText = ""
    @State private var availableUsers: [UserModel] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo púrpura igual que otras pantallas
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
                    // Header con título
                    HStack {
                        Text("Amigos")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Barra de búsqueda (igual que FriendsListView)
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            
                            TextField("Buscar amigos", text: $searchText)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // Lista de usuarios disponibles para añadir
                    if availableUsers.isEmpty {
                        // Estado vacío - no hay usuarios para añadir
                        VStack(spacing: 24) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            VStack(spacing: 12) {
                                Text("No hay usuarios disponibles")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Ya tienes a todos los usuarios\\ncomo amigos o no hay más usuarios")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                    } else {
                        // Lista de usuarios disponibles con botón +
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(availableUsers) { user in
                                    FriendRowView(
                                        friend: user,
                                        mode: .add,
                                        onAction: {
                                            addFriend(user)
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Inicio")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .searchable(text: $searchText, prompt: "Buscar usuarios")
        .onChange(of: searchText) { _, newValue in
            loadAvailableUsers()
        }
        .onAppear {
            loadAvailableUsers()
        }
    }
    
    private func loadAvailableUsers() {
        availableUsers = friendsRepository.getAvailableUsers(filter: searchText)
    }
    
    private func addFriend(_ user: UserModel) {
        let success = friendsRepository.addFriend(user)
        if success {
            // Recargar lista de usuarios disponibles
            loadAvailableUsers()
            // Notificar que se añadió un amigo
            onFriendAdded()
            
            // Mostrar feedback visual (opcional)
        }
    }
}

#Preview {
    AddFriendView(
        friendsRepository: HybridFriendsRepository(),
        onFriendAdded: {}
    )
}