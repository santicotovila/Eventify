//
//  CreateEventQuickView.swift
//  EventifyAI
//
//  Created by Javier Gomez on 6/9/25.
//

import SwiftUI

/// Vista rápida para crear eventos desde el tab
struct CreateEventQuickView: View {
    
    let createEventUseCase: CreateEventUseCaseProtocol
    @State private var showingCreateEvent = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 16) {
                    Text("Crear Nuevo Evento")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Organiza tu próximo evento de forma rápida y sencilla")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button("Empezar") {
                    showingCreateEvent = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(.headline)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Nuevo Evento")
        }
        .sheet(isPresented: $showingCreateEvent) {
            CreateEventView(
                createEventUseCase: createEventUseCase,
                onEventCreated: {
                    // Actualizar la lista de eventos
                    NotificationCenter.default.post(name: .eventWasCreated, object: nil)
                }
            )
        }
    }
}
