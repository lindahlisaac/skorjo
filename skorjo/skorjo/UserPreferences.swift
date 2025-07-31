import Foundation
import SwiftData

@Model
class UserPreferences {
    var hasSeenWelcomeScreen: Bool = false
    var preferredTheme: String = "system" // "light", "dark", "system"
    var notificationsEnabled: Bool = true
    var defaultActivityType: String = "Run"
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init() {
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func markWelcomeScreenSeen() {
        hasSeenWelcomeScreen = true
        updatedAt = Date()
    }
    
    func updateTheme(_ theme: String) {
        preferredTheme = theme
        updatedAt = Date()
    }
    
    func toggleNotifications() {
        notificationsEnabled.toggle()
        updatedAt = Date()
    }
    
    func setDefaultActivityType(_ type: String) {
        defaultActivityType = type
        updatedAt = Date()
    }
} 