//
//  EventsViewModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 9/9/25.
//

import Foundation
import Combine
import SwiftData

// ViewModel para lista de eventos
@Observable
final class EventsViewModel {
    var eventsData = [EventModel]()
    var filterUI: String = ""
    
    @ObservationIgnored
    private var useCaseEvents: EventsUseCaseProtocol
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()  // Para manejar Combine subscriptions
    
    init(useCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.useCaseEvents = useCase
        setupNotificationListeners()
    }
    
    // Para SwiftData injection
    func setModelContext(_ modelContext: ModelContext) {
        self.useCaseEvents = EventsUseCase(modelContext: modelContext)
        Task {
            await self.getEvents()
        }
    }
    
    // Configurar listeners de NotificationCenter
    private func setupNotificationListeners() {
        // Actualizar lista cuando se crea evento
        NotificationCenter.default.eventWasCreatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.getEvents()
                }
            }
            .store(in: &cancellables)
        
        // Refrescar al hacer login
        NotificationCenter.default.userDidSignInPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.getEvents()
                }
            }
            .store(in: &cancellables)
        
        // Limpiar al hacer logout
        NotificationCenter.default.userDidSignOutPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.eventsData = []
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func getEvents(newSearch: String = "") async {
        let data = await useCaseEvents.getEvents(filter: newSearch)
        self.eventsData = data
    }
    
    @MainActor
    func createEvent(_ event: EventModel) async -> Bool {
        let success = await useCaseEvents.createEvent(event)
        
        if success {
            await getEvents()
        }
        
        return success
    }
}