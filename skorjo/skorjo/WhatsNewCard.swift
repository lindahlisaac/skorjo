import SwiftUI
import SwiftData

struct WhatsNewCard: View {
    @Environment(\.modelContext) private var context
    @Query private var userPreferences: [UserPreferences]
    
    @State private var isVisible = true
    @State private var showingChangelog = false
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    // Get version data from VersionHistory
    private var currentVersion: VersionEntry? {
        VersionHistory.latestVersion
    }
    
    var body: some View {
        if isVisible && shouldShowWhatsNew {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text(currentVersion?.title ?? "What's New")
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
                    ForEach(currentVersion?.features ?? [], id: \.self) { feature in
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
                
                // Buttons
                VStack(spacing: 8) {
                    Button(action: { showingChangelog = true }) {
                        Text("View Full Changelog")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(lilac)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(lilac.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: dismissCard) {
                        Text("Got it!")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(lilac)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.primary.opacity(0.1), radius: 8, x: 0, y: 2)
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .sheet(isPresented: $showingChangelog) {
                ChangelogView()
            }
        }
    }
    
    private var currentAppVersion: String {
        VersionHistory.current
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

#Preview {
    WhatsNewCard()
        .modelContainer(for: [JournalEntry.self, UserPreferences.self], inMemory: true)
} 