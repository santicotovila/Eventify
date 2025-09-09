//
//  SplashView.swift
//  EventifyAI
//
//  Created by Santiago Coto Vila on 9/9/25.
//

import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @Binding var isInitialized: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(scale)
                
                Text("EventifyAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                Text("Organizando eventos inteligentes")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(opacity)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .opacity(opacity)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    scale = 1.0
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
