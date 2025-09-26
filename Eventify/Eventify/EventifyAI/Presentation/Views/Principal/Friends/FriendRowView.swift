import SwiftUI

// Row de amigo siguiendo el estilo exacto del Figma
struct FriendRowView: View {
    let friend: UserModel
    let mode: FriendRowMode
    let onAction: () -> Void
    
    enum FriendRowMode {
        case normal        // Vista normal (sin botones)
        case remove        // Modo eliminar (botón rojo -)
        case add          // Modo añadir (botón verde +)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar circular con inicial
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Circle()
                    .fill(Color.purple.opacity(0.8))
                    .frame(width: 45, height: 45)
                    .overlay(
                        Text(String(friend.name.prefix(1)))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
            }
            
            // Info del amigo
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(friend.email)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Botón de acción según el modo
            if mode != .normal {
                Button(action: onAction) {
                    actionButton
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch mode {
        case .remove:
            // Botón rojo para eliminar (como en Figma)
            Circle()
                .fill(Color.red)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
                
        case .add:
            // Botón verde para añadir (como en Figma)
            Circle()
                .fill(Color.green)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
                
        case .normal:
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // Vista normal
        FriendRowView(
            friend: UserModel.friendPreview1,
            mode: .normal,
            onAction: {}
        )
        
        // Modo eliminar
        FriendRowView(
            friend: UserModel.friendPreview2,
            mode: .remove,
            onAction: {}
        )
        
        // Modo añadir
        FriendRowView(
            friend: UserModel.availableUser1,
            mode: .add,
            onAction: {}
        )
    }
    .padding()
    .background(Color.purple.opacity(0.3))
}