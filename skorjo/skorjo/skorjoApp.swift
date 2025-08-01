//
//  skorjoApp.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData
import UserNotifications

extension Notification.Name {
    static let openWeeklyRecap = Notification.Name("openWeeklyRecap")
}

@main
struct SkorjoApp: App {
    @State private var showWeeklyRecapFromNotification = false
    
    var body: some Scene {
        WindowGroup {
            LoadingView()
                .font(.system(size: 17, design: .rounded)) // 👈 Applies to all child views
                .sheet(isPresented: $showWeeklyRecapFromNotification) {
                    WeeklyRecapEntryFormView()
                }
                .onReceive(NotificationCenter.default.publisher(for: .openWeeklyRecap)) { _ in
                    showWeeklyRecapFromNotification = true
                }
        }
        .modelContainer(for: [JournalEntry.self, UserPreferences.self])
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        
        switch identifier {
        case "CREATE_RECAP":
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .openWeeklyRecap, object: nil)
            }
        case "REMIND_LATER":
            // Schedule another reminder for later (optional enhancement)
            print("User chose to be reminded later")
        default:
            // Handle default tap on notification
            if response.notification.request.identifier == "weekly-recap-reminder" || 
               response.notification.request.identifier == "test-notification" {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .openWeeklyRecap, object: nil)
                }
            }
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
