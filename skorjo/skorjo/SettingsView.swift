import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var userPreferences: [UserPreferences]
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        NavigationStack {
            List {
                if let preferences = userPreferences.first {
                    Section("Appearance") {
                        Picker("Theme", selection: Binding(
                            get: { preferences.preferredTheme },
                            set: { newValue in
                                preferences.preferredTheme = newValue
                                preferences.updatedAt = Date()
                                try? context.save()
                            }
                        )) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                    }
                    
                    Section("Defaults") {
                        Picker("Default Activity Type", selection: Binding(
                            get: { preferences.defaultActivityType },
                            set: { newValue in
                                preferences.defaultActivityType = newValue
                                preferences.updatedAt = Date()
                                try? context.save()
                            }
                        )) {
                            Text("Run").tag("Run")
                            Text("Walk").tag("Walk")
                            Text("Hike").tag("Hike")
                            Text("Bike").tag("Bike")
                            Text("Swim").tag("Swim")
                            Text("Lift").tag("Lift")
                            Text("Yoga").tag("Yoga")
                            Text("Golf").tag("Golf")
                            Text("Other").tag("Other")
                        }
                    }
                    
                    Section("Notifications") {
                        Toggle("Enable Notifications", isOn: Binding(
                            get: { preferences.notificationsEnabled },
                            set: { newValue in
                                preferences.notificationsEnabled = newValue
                                preferences.updatedAt = Date()
                                try? context.save()
                            }
                        ))
                    }
                    
                    Section("Data") {
                        HStack {
                            Text("Total Entries")
                            Spacer()
                            Text("\(preferences.createdAt.timeIntervalSince1970, specifier: "%.0f")")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Last Updated")
                            Spacer()
                            Text(preferences.updatedAt.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
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

#Preview {
    SettingsView()
        .modelContainer(for: [JournalEntry.self, UserPreferences.self])
} 