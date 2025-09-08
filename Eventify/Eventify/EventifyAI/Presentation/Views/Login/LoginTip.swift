import SwiftUI
import TipKit

struct LoginTip: Tip {
    var title: Text {
        Text("Bienvenido a EventifyAI")
    }
    
    var message: Text? {
        Text("Crea una cuenta para empezar a organizar eventos inteligentes con IA.")
    }
    
    var image: Image? {
        Image(systemName: "sparkles")
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(3)
        
        ]
    }
}

struct LoginFormTip: Tip {
    var title: Text {
        Text("Consejos para tu contraseña")
    }
    
    var message: Text? {
        Text("Tu contraseña debe tener al menos 6 caracteres para mayor seguridad.")
    }
    
    var image: Image? {
        Image(systemName: "lock.shield")
    }
}

struct QuickStartTip: Tip {
    var title: Text {
        Text("Inicio rápido")
    }
    
    var message: Text? {
        Text("¿No tienes cuenta? Toca 'Regístrate' para crear una nueva cuenta en segundos.")
    }
    
    var image: Image? {
        Image(systemName: "person.badge.plus")
    }
    
    var options: [TipOption] {
        [
            Tips.MaxDisplayCount(1)
            
        ]
    }
}

#Preview {
    VStack(spacing: 20) {
        TipView(LoginTip())
        TipView(LoginFormTip())
        TipView(QuickStartTip())
    }
    .padding()
}
