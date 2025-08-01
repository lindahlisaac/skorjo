import SwiftUI

struct ChangelogView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    private let changelogData = [
        ChangelogEntry(
            version: "0.1.0",
            date: "July 2025",
            changes: [
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
        ChangelogEntry(
            version: "0.0.1",
            date: "Initial Beta",
            changes: [
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What's New in Skorjo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(lilac)
                        
                        Text("Track all the improvements and new features we've added to make your fitness journaling experience better.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Changelog Entries
                    ForEach(changelogData, id: \.version) { entry in
                        ChangelogEntryView(entry: entry)
                    }
                    
                    // Footer
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Thank you for using Skorjo!")
                            .font(.headline)
                            .foregroundColor(lilac)
                        
                        Text("We're constantly working to improve your fitness journaling experience. If you have suggestions or feedback, we'd love to hear from you.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("Changelog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ChangelogEntry: Identifiable {
    let id = UUID()
    let version: String
    let date: String
    let changes: [String]
}

struct ChangelogEntryView: View {
    let entry: ChangelogEntry
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Version Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Version \(entry.version)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(lilac)
                    
                    Text(entry.date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Version Badge
                Text(entry.version)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(lilac.opacity(0.2))
                    .foregroundColor(lilac)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Changes List
            VStack(alignment: .leading, spacing: 8) {
                ForEach(entry.changes, id: \.self) { change in
                    HStack(alignment: .top, spacing: 12) {
                        Text("•")
                            .foregroundColor(lilac)
                            .fontWeight(.bold)
                        
                        Text(change)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ChangelogView()
} 