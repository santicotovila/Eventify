import SwiftUI

struct RootView: View {
    
    @State private var appStateVM: AppStateVM
    
    init() {
        let loginUseCase = AppFactory.shared.makeLoginUseCase()
        self._appStateVM = State(wrappedValue: AppStateVM(loginUseCase: loginUseCase))
    }
    
    var body: some View {
        Group {
            if appStateVM.isUserAuthenticated {
                PrincipalView(loginUseCase: AppFactory.shared.makeLoginUseCase())
            } else {
                LoginView()
            }
        }
        .onAppear {
            appStateVM.checkAuthenticationState()
        }
    }
}

#Preview {
    RootView()
}