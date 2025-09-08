import SwiftUI

struct LoaderView: View {
    let message: String
    let showProgress: Bool
    
    @State private var isAnimating = false
    
    init(message: String = "Cargando...", showProgress: Bool = true) {
        self.message = message
        self.showProgress = showProgress
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if showProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.2)
            } else {
                // Custom animated loader
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(0.2 * Double(index)),
                                value: isAnimating
                            )
                    }
                }
                .onAppear {
                    isAnimating = true
                }
            }
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }
}

struct LoaderOverlay: View {
    let message: String
    
    init(message: String = "Cargando...") {
        self.message = message
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                
                Text(message)
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            .padding(24)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
        }
    }
}

#Preview {
    Group {
        LoaderView()
        
        LoaderView(message: "Guardando evento...", showProgress: false)
        
        ZStack {
            Color.gray.opacity(0.1)
            LoaderOverlay(message: "Sincronizando...")
        }
    }
}