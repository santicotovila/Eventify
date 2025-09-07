import SwiftUI

// Esta es la pantalla principal que decide qué mostrar
// Si hay usuario logueado = muestra la app
// Si no hay usuario = muestra el login
struct ContentView: View {
    
    // Estas son las cosas que necesita esta pantalla
    @Binding var currentUser: User?
    let onUserSignedIn: (User) -> Void
    let onUserSignedOut: () -> Void
    
    // Aquí va lo que se ve en la pantalla
    var body: some View {
        Group {
            if let user = currentUser {
                // Ya hay alguien logueado - mostrar la app principal
                MainAppView(
                    user: user,
                    onSignOut: {
                        onUserSignedOut()
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            } else {
                // Nadie está logueado - mostrar pantalla de login
                LoginView(
                    onUserSignedIn: { user in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            onUserSignedIn(user)
                        }
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentUser?.id)
    }
}