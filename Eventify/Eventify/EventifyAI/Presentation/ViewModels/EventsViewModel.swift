//
//  EventsViewModel.swift
//  EventifyAI
//
//  Created by Javier Gómez on 9/9/25.
//

import Foundation
import Combine
import SwiftData

@Observable
final class EventsViewModel {
    var eventsData = [EventModel]()
    var filterUI: String = ""
    
    @ObservationIgnored
    private var useCaseEvents: EventsUseCaseProtocol
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    init(useCase: EventsUseCaseProtocol = EventsUseCase()) {
        self.useCaseEvents = useCase
        setupNotificationListeners()
    }
    
    // Método para inyectar modelContext después de init
    func setModelContext(_ modelContext: ModelContext) {
        // Recrear UseCase con contexto
        self.useCaseEvents = EventsUseCase(modelContext: modelContext)
        // Cargar eventos con el nuevo contexto
        Task {
            await self.getEvents()
        }
    }
    
    // MARK: - Notification Listeners
    private func setupNotificationListeners() {
        // Escuchar cuando se crea un nuevo evento para actualizar la lista automáticamente
        NotificationCenter.default.eventWasCreatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task {
                    await self?.getEvents()
                }
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