import SwiftUI

struct FriendsListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var friendsRepository = HybridFriendsRepository()
    @State private var searchText = ""
    @State private var friends: [UserModel] = []
    @State private var isEditMode = false
    @State private var showAddFriends = false
    
    var body: some View {
            ZStack {
                // Fondo púrpura igual que EventsListView
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
                    // Header con título y botones
                    HStack {
                        Text("Amigos")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Botón Añadir Amigos
                        Button(action: {
                            showAddFriends = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Añadir")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Botón Eliminar/Cancelar
                        Button(action: {
                            isEditMode.toggle()
                        }) {
                            Text(isEditMode ? "Cancelar" : "Eliminar")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(isEditMode ? Color.red.opacity(0.7) : Color.white.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Barra de búsqueda 
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
                    
                    // Lista de amigos
                    if friends.isEmpty {
                        // Estado vacío
                        VStack(spacing: 24) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            VStack(spacing: 12) {
                                Text("No hay amigos")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Añade tu primer amigo y comienza\\na conectar con otros usuarios")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                    } else {
                        // Lista con amigos
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(friends) { friend in
                                    FriendRowView(
                                        friend: friend,
                                        mode: isEditMode ? .remove : .normal,
                                        onAction: {
                                            removeFriend(friend.id)
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
        .searchable(text: $searchText, prompt: "Buscar amigos")
        .onChange(of: searchText) { _, newValue in
            loadFriends()
        }
        .onAppear {
            loadFriends()
        }
        .sheet(isPresented: $showAddFriends) {
            AddFriendView(friendsRepository: friendsRepository) {
                loadFriends() // Refrescar lista cuando se añaden amigos
            }
        }
    }
    
    private func loadFriends() {
        friends = friendsRepository.getFriends(filter: searchText)
    }
    
    private func removeFriend(_ friendId: String) {
        let success = friendsRepository.removeFriend(userId: friendId)
        if success {
            loadFriends()
        }
    }
}

#Preview {
    FriendsListView()
}
