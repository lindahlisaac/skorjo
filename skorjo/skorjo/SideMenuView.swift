import SwiftUI
import SwiftData

struct SideMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var userPreferences: [UserPreferences]
    
    @State private var showAbout = false
    @State private var showSettings = false
    @State private var showBrowseEntries = false
    @State private var showExport = false
    @State private var showImport = false
    @State private var showChangelog = false
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Skorjo")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(lilac)
                        Text("Your personal fitness journal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                Section("Navigation") {
                    Button(action: { showAbout = true }) {
                        Label("About", systemImage: "info.circle")
                    }
                    
                    Button(action: { showSettings = true }) {
                        Label("Settings", systemImage: "gear")
                    }
                    
                    Button(action: { showBrowseEntries = true }) {
                        Label("Browse Entries", systemImage: "list.bullet")
                    }
                }
                
                Section("Data") {
                    Button(action: { showExport = true }) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: { showImport = true }) {
                        Label("Import Data", systemImage: "square.and.arrow.down")
                    }
                }
                
                Section("Support") {
                    Button(action: { showChangelog = true }) {
                        Label("Changelog", systemImage: "list.bullet.clipboard")
                    }
                    
                    Button(action: resetEntryOrder) {
                        Label("Reset Entry Order", systemImage: "arrow.clockwise")
                    }
                    
                    Button(action: resetWelcomeScreen) {
                        Label("Reset Welcome Screen", systemImage: "house")
                    }
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showBrowseEntries) {
            BrowseEntriesView()
        }
        .sheet(isPresented: $showExport) {
            ExportView()
        }
        .sheet(isPresented: $showImport) {
            ImportView()
        }
        .sheet(isPresented: $showChangelog) {
            ChangelogView()
        }
    }
    
    private func resetEntryOrder() {
        if let preferences = userPreferences.first {
            preferences.resetEntryTypeOrder()
            try? context.save()
        }
    }
    
    private func resetWelcomeScreen() {
        if let preferences = userPreferences.first {
            preferences.hasSeenWelcomeScreen = false
            try? context.save()
        }
    }
}

#Preview {
    SideMenuView()
        .modelContainer(for: [JournalEntry.self, UserPreferences.self])
} 