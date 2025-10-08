import Foundation
import SwiftUI
import CoreGraphics

struct ConstantsApp {
    
    // MARK: - App Information
    static let appName = "EventifyAI"
    static let appVersion = "1.0.0"
    
    // MARK: - User Defaults Keys
    struct UserDefaults {
        static let isFirstLaunch = "is_first_launch"
        static let lastSyncDate = "last_sync_date"
        static let isDarkModeEnabled = "is_dark_mode_enabled"
    }
    
    // MARK: - Keychain Keys
    struct Keychain {
        static let currentUserId = "current_user_id"
        static let userToken = "user_token"
        static let userEmail = "user_email"
    }
    
    // MARK: - Notifications
    struct Notifications {
        static let userDidSignIn = "userDidSignIn"
        static let userDidSignOut = "userDidSignOut"
        static let eventWasCreated = "eventWasCreated"
        static let eventWasUpdated = "eventWasUpdated"
    }
    
    // MARK: - UI Constants
    struct UI {
        static let cornerRadius: CGFloat = 12.0
        static let defaultPadding: CGFloat = 16.0
        static let buttonHeight: CGFloat = 44.0
        static let animationDuration: Double = 0.3
    }
    
    // MARK: - Colors
    struct Colors {
        static let gris = Color(red: 0.75, green: 0.78, blue: 0.82) // #BFC7D1
    }
    
    // MARK: - Validation
    struct Validation {
        static let minPasswordLength = 8
        static let maxEventTitleLength = 100
        static let maxEventDescriptionLength = 500
    }
    
    // MARK: - API
    struct API {
        static let baseURL = "http://localhost:8080/api"
        static let timeout: TimeInterval = 30.0
    }
}
