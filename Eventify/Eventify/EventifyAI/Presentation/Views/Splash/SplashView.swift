//
//  SplashView.swift
//  EventifyAI
//
//  Created by Santiago Coto Vila on 9/9/25.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.0
    @State private var opacity: Double = 0.0
    @Binding var isInitialized: Bool
    
    var body: some View {
        ZStack {
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
            
            VStack(spacing: 24) {
                // Logo circular con iconos como en el diseño
                ZStack {
                    Image("Logo-Eventify")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                }
                .scaleEffect(scale)
                
                Text("EventifyAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .padding()
                    .scaleEffect(1.6)
                
                Text("Organizando eventos de manera inteligente")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    scale = 1.6
                    opacity = 1.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut) {
                        isInitialized = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView(isInitialized: .constant(false))
}
