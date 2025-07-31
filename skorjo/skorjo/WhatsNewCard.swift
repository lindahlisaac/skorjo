import SwiftUI
import SwiftData

struct WhatsNewCard: View {
    @Environment(\.modelContext) private var context
    @Query private var userPreferences: [UserPreferences]
    
    @State private var isVisible = true
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    // Define what's new for each version
    private let whatsNewData: [String: WhatsNewVersion] = [
        "1.1.0": WhatsNewVersion(
            version: "1.1.0",
            title: "What's New in Skorjo",
            features: [
                "🎯 New Activity Types - Yoga and Golf with score tracking",
                "📱 Beautiful Welcome Screen - Personal introduction to Skorjo",
                "📊 Enhanced Export - JSON format with complete data",
                "🔄 Import Feature - Restore your journal data anytime",
                "✨ Improved UI - Cleaner design and better navigation"
            ]
        )
    ]
    
    var body: some View {
        if isVisible && shouldShowWhatsNew {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(whatsNewData[currentAppVersion]?.title ?? "What's New")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: dismissCard) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                }
                
                // Features list
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(whatsNewData[currentAppVersion]?.features ?? [], id: \.self) { feature in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(lilac)
                                .font(.body)
                            
                            Text(feature)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                // Dismiss button
                Button(action: dismissCard) {
                    Text("Got it!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(lilac)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(lilac.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 2)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
    
    private var currentAppVersion: String {
        // In a real app, you'd get this from your app's version
        // For now, we'll use a hardcoded version for testing
        return "1.1.0"
    }
    
    private var shouldShowWhatsNew: Bool {
        guard let preferences = userPreferences.first else { return false }
        return preferences.lastSeenAppVersion != currentAppVersion
    }
    
    private func dismissCard() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isVisible = false
        }
        
        // Mark this version as seen
        if let preferences = userPreferences.first {
            preferences.markAppVersionSeen(currentAppVersion)
            try? context.save()
        }
    }
}

struct WhatsNewVersion {
    let version: String
    let title: String
    let features: [String]
}

#Preview {
    WhatsNewCard()
        .modelContainer(for: [JournalEntry.self, UserPreferences.self], inMemory: true)
} 