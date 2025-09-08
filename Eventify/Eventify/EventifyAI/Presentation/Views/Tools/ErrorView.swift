import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String = "Error",
        message: String,
        actionTitle: String? = "Intentar de nuevo",
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
    }
}

#Preview {
    Group {
        ErrorView(
            message: "No se pudieron cargar los eventos. Verifica tu conexión a internet.",
            action: {}
        )
        
        ErrorView(
            title: "Sin conexión",
            message: "No hay conexión a internet disponible.",
            actionTitle: "Configurar",
            action: {}
        )
        
        ErrorView(
            title: "Acceso denegado",
            message: "No tienes permisos para realizar esta acción.",
            actionTitle: nil,
            action: nil
        )
    }
}