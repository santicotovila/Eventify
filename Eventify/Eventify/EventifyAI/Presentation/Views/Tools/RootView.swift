import SwiftUI

struct RootView: View {
    
    @State private var appStateVM: AppStateVM
     
    init() {
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        self._appStateVM = State(wrappedValue: AppStateVM(loginUseCase: loginUseCase))
    }
    
    var body: some View {
        Group {
            if appStateVM.isUserAuthenticated {
                HomeView()
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
