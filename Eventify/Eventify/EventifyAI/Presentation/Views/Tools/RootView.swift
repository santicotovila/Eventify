import SwiftUI
import SwiftData

// Vista raíz de la app - maneja navegación entre login y home según estado de auth
struct RootView: View {
    
    // @State para estado global de la app
    @State private var appStateVM: AppStateVM
    @Environment(\.modelContext) private var modelContext
     
    // Dependency injection manual en el init
    init() {
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        self._appStateVM = State(wrappedValue: AppStateVM(loginUseCase: loginUseCase))
    }
    
    var body: some View {
        // Group para navegación condicional sin animación
        Group {
            if appStateVM.isUserAuthenticated {
                HomeView()
                    .environment(appStateVM)
                    .environment(\.modelContext, modelContext)
            } else {
                LoginView()
                    .environment(appStateVM)
                    .environment(\.modelContext, modelContext)
            }
        }
        .onAppear {
            // Verificar estado de autenticación al aparecer
            appStateVM.checkAuthenticationState()
        }
    }
}

#Preview {
    RootView()
}
