import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var userPreferences: [UserPreferences]
    
    @State private var notificationPermissionGranted = false
    @State private var showingPermissionAlert = false
    
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
                        Button(action: requestNotificationPermissionManually) {
                            Label("Request Notification Permission", systemImage: "bell.badge.fill")
                        }
                        .foregroundColor(lilac)
                        
                        Toggle("Enable Notifications", isOn: Binding(
                            get: { preferences.notificationsEnabled },
                            set: { newValue in
                                if newValue {
                                    requestNotificationPermission { granted in
                                        if granted {
                                            preferences.notificationsEnabled = true
                                            scheduleWeeklyRecapNotification()
                                        } else {
                                            showingPermissionAlert = true
                                        }
                                    }
                                } else {
                                    cancelWeeklyRecapNotification()
                                    preferences.notificationsEnabled = false
                                }
                                preferences.updatedAt = Date()
                                try? context.save()
                            }
                        ))
                        
                        if preferences.notificationsEnabled {
                            Picker("Day of Week", selection: Binding(
                                get: { preferences.weeklyRecapDay },
                                set: { newDay in
                                    preferences.weeklyRecapDay = newDay
                                    preferences.updatedAt = Date()
                                    try? context.save()
                                    scheduleWeeklyRecapNotification()
                                }
                            )) {
                                Text("Sunday").tag(1)
                                Text("Monday").tag(2)
                                Text("Tuesday").tag(3)
                                Text("Wednesday").tag(4)
                                Text("Thursday").tag(5)
                                Text("Friday").tag(6)
                                Text("Saturday").tag(7)
                            }
                            
                            DatePicker("Time", selection: Binding(
                                get: { 
                                    Calendar.current.date(from: DateComponents(hour: preferences.weeklyRecapHour, minute: preferences.weeklyRecapMinute)) ?? Date()
                                },
                                set: { newDate in
                                    let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    preferences.weeklyRecapHour = components.hour ?? 19
                                    preferences.weeklyRecapMinute = components.minute ?? 0
                                    preferences.updatedAt = Date()
                                    try? context.save()
                                    scheduleWeeklyRecapNotification()
                                }
                            ), displayedComponents: .hourAndMinute)
                            
                            Button(action: sendTestNotification) {
                                Label("Send Test Notification", systemImage: "bell.badge")
                            }
                            .foregroundColor(lilac)
                            
                            Button(action: sendImmediateTestNotification) {
                                Label("Send Immediate Test", systemImage: "bolt")
                            }
                            .foregroundColor(.orange)
                        }
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
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to receive weekly recap reminders.")
        }
    }
    
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    private func scheduleWeeklyRecapNotification() {
        guard let preferences = userPreferences.first, preferences.notificationsEnabled else { return }
        
        // Cancel existing notifications
        cancelWeeklyRecapNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Reflection Time 🌟"
        content.body = "Time for your weekly reflection! How did your training week feel?"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_RECAP"
        
        // Create custom day trigger
        var dateComponents = DateComponents()
        dateComponents.weekday = preferences.weeklyRecapDay
        dateComponents.hour = preferences.weeklyRecapHour
        dateComponents.minute = preferences.weeklyRecapMinute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-recap-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Weekly recap notification scheduled successfully")
            }
        }
    }
    
    private func cancelWeeklyRecapNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weekly-recap-reminder"])
    }
    
    private func sendTestNotification() {
        // First check notification authorization status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("Notification authorization status: \(settings.authorizationStatus.rawValue)")
                print("Alert setting: \(settings.alertSetting.rawValue)")
                print("Sound setting: \(settings.soundSetting.rawValue)")
                print("Badge setting: \(settings.badgeSetting.rawValue)")
                
                if settings.authorizationStatus == .authorized {
                    let content = UNMutableNotificationContent()
                    content.title = "Weekly Reflection Time 🌟"
                    content.body = "Time for your weekly reflection! How did your training week feel?"
                    content.sound = .default
                    content.categoryIdentifier = "WEEKLY_RECAP"
                    
                    // Trigger notification in 2 seconds
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
                    let request = UNNotificationRequest(identifier: "test-notification", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Error sending test notification: \(error)")
                        } else {
                            print("Test notification scheduled successfully")
                        }
                    }
                } else {
                    print("Notifications not authorized. Status: \(settings.authorizationStatus.rawValue)")
                }
            }
        }
    }
    
    private func sendImmediateTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Reflection Time 🌟"
        content.body = "Time for your weekly reflection! How did your training week feel?"
        content.sound = .default
        
        // Send immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "immediate-test", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending immediate test: \(error)")
            } else {
                print("Immediate test notification scheduled")
            }
        }
    }
    
    private func requestNotificationPermissionManually() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted manually")
                    // Update the toggle to reflect the granted permission
                    if let preferences = self.userPreferences.first {
                        preferences.notificationsEnabled = true
                        try? self.context.save()
                    }
                } else {
                    print("Notification permission denied manually")
                    if let error = error {
                        print("Error: \(error)")
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