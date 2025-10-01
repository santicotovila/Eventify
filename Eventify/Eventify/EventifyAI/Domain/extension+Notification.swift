import Foundation
import Combine

extension Notification.Name {
    
    // MARK: - User Authentication
    static let userDidSignIn = Notification.Name(ConstantsApp.Notifications.userDidSignIn)
    static let userDidSignOut = Notification.Name(ConstantsApp.Notifications.userDidSignOut)
    
    // MARK: - Events
    static let eventWasCreated = Notification.Name(ConstantsApp.Notifications.eventWasCreated)
    static let eventWasUpdated = Notification.Name(ConstantsApp.Notifications.eventWasUpdated)
}

extension NotificationCenter {
    
    // MARK: - User Authentication Notifications
    
    func postUserDidSignIn(user: UserModel) {
        post(name: .userDidSignIn, object: user)
    }
    
    func postUserDidSignOut() {
        post(name: .userDidSignOut, object: nil)
    }
    
    // MARK: - Event Notifications
    
    func postEventWasCreated(event: EventModel) {
        post(name: .eventWasCreated, object: event)
    }
    
    func postEventWasUpdated(event: EventModel) {
        post(name: .eventWasUpdated, object: event)
    }
    
    
    func addObserver(
        _ observer: Any,
        selector: Selector,
        name: Notification.Name,
        object: Any? = nil
    ) {
        addObserver(observer, selector: selector, name: name, object: object)
    }
    
    func removeObserver(_ observer: Any, name: Notification.Name) {
        removeObserver(observer, name: name, object: nil)
    }
    
    
    var userDidSignInPublisher: AnyPublisher<UserModel, Never> {
        NotificationCenter.default
            .publisher(for: .userDidSignIn)
            .compactMap { $0.object as? UserModel }
            .eraseToAnyPublisher()
    }
    
    var userDidSignOutPublisher: AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: .userDidSignOut)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    var eventWasCreatedPublisher: AnyPublisher<EventModel, Never> {
        NotificationCenter.default
            .publisher(for: .eventWasCreated)
            .compactMap { $0.object as? EventModel }
            .eraseToAnyPublisher()
    }
    
    var eventWasUpdatedPublisher: AnyPublisher<EventModel, Never> {
        NotificationCenter.default
            .publisher(for: .eventWasUpdated)
            .compactMap { $0.object as? EventModel }
            .eraseToAnyPublisher()
    }
}