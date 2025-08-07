import Foundation

struct VersionEntry: Identifiable, Comparable {
    let id: String // version number
    let date: String
    let title: String
    let features: [String] // Key features for What's New card
    let allFeatures: [String] // Complete list for changelog
    
    // Implement Comparable to sort versions
    static func < (lhs: VersionEntry, rhs: VersionEntry) -> Bool {
        // Split version strings into components
        let lhsComponents = lhs.id.split(separator: ".").compactMap { Int($0) }
        let rhsComponents = rhs.id.split(separator: ".").compactMap { Int($0) }
        
        // Compare components
        for i in 0..<min(lhsComponents.count, rhsComponents.count) {
            if lhsComponents[i] != rhsComponents[i] {
                return lhsComponents[i] < rhsComponents[i]
            }
        }
        return lhsComponents.count < rhsComponents.count
    }
}

enum VersionHistory {
    static let current = "0.1.0" // Current app version
    
    static let versions: [VersionEntry] = [
        VersionEntry(
            id: "0.1.0",
            date: "July 2025",
            title: "What's New in Skorjo",
            features: [
                "🏆 Introduced Milestone entries to celebrate your achievements",
                "⛳ Added Golf and Yoga activity types for more tracking options",
                "🤕 Enhanced injury tracking with side selection and healing status",
                "🔔 Added weekly recap notifications with custom scheduling",
                "📱 New menu system with About, Settings, and Export features"
            ],
            allFeatures: [
                "⛳ Added Golf activity type with score tracking for your rounds",
                "🧘 Added Yoga activity type for mindful movement sessions",
                "🏆 Introduced Milestone entries to celebrate your achievements",
                "💚 Enhanced injury tracking with 'healed' status marking",
                "📝 Added comprehensive notes field for detailed injury documentation",
                "🔄 Added injury side tracking (left/right) for precise injury management",
                "⚙️ Implemented user preferences system for personalized experience",
                "🎯 Added drag-and-drop reordering for customizable entry type tiles",
                "✨ Introduced 'What's New' popup to highlight new features after updates",
                "📱 Added About section with Skorjo's mission and purpose",
                "🍔 Implemented hamburger menu for easy navigation and settings access",
                "📤 Enhanced data export with JSON format and complete data model support",
                "🔔 Added weekly recap notifications with customizable day and time preferences"
            ]
        ),
        VersionEntry(
            id: "0.0.1",
            date: "Initial Beta",
            title: "Initial Release",
            features: [
                "📝 Basic journal entry creation",
                "🏃 Activity tracking (Run, Walk, Hike, Bike, Swim, Lift)",
                "🧠 Reflection entries for mental tracking",
                "📅 Weekly recap entries",
                "🤕 Injury tracking with check-ins"
            ],
            allFeatures: [
                "📝 Basic journal entry creation",
                "🏃 Activity tracking (Run, Walk, Hike, Bike, Swim, Lift, Other)",
                "🧠 Reflection entries for mental tracking",
                "📅 Weekly recap entries",
                "🤕 Injury tracking with check-ins",
                "📊 Basic data export functionality",
                "🎨 Clean, intuitive user interface",
                "📱 iOS native design with SwiftUI"
            ]
        )
    ]
    
    static var latestVersion: VersionEntry? {
        versions.max()
    }
    
    static func version(_ id: String) -> VersionEntry? {
        versions.first { $0.id == id }
    }
}
