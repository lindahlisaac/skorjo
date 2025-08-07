import Foundation
import SwiftData

@Model
class UserPreferences {
    var hasSeenWelcomeScreen: Bool = false
    var lastSeenAppVersion: String = "1.0.0"
    var entryTypeOrder: [String] = ["Activity", "Reflection", "Weekly Recap", "Injury", "Milestone"]
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
    
    func markAppVersionSeen(_ version: String) {
        lastSeenAppVersion = version
        updatedAt = Date()
    }
    
    func updateEntryTypeOrder(_ newOrder: [String]) {
        entryTypeOrder = newOrder
        updatedAt = Date()
    }
    
    func resetEntryTypeOrder() {
        entryTypeOrder = ["Activity", "Reflection", "Weekly Recap", "Injury", "Milestone"]
        updatedAt = Date()
    }
} 