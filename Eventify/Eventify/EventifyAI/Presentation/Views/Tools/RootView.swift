import SwiftUI

struct RootView: View {
    
    @StateObject private var appStateVM: AppStateVM
     
    init() {
        let loginRepository = DefaultLoginRepository()
        let loginUseCase = LoginUseCase(loginRepository: loginRepository)
        self._appStateVM = StateObject(wrappedValue: AppStateVM(loginUseCase: loginUseCase))
    }
    
    var body: some View {
        Group {
            if appStateVM.isUserAuthenticated {
                HomeView()
                    .environmentObject(appStateVM)
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
