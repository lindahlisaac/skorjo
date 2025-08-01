//
//  LoadingView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/12/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct LoadingView: View {
    @State private var isActive = false
    @State private var showWelcome = false
    @Environment(\.colorScheme) private var colorScheme
    @Query private var userPreferences: [UserPreferences]

    var body: some View {
        if showWelcome {
            WelcomeView(showWelcome: $showWelcome, onComplete: transitionToMainApp)
        } else if isActive {
            ContentView()
        } else {
            VStack {
                Spacer()

                Text("Skorjo")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 20)

                Text("Not every step needs to be shared.\nNot every feeling needs a like.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(colorScheme == .dark ? Color(red: 0.784, green: 0.635, blue: 0.784) : .primary)
                    .padding(.horizontal)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .ignoresSafeArea()
                    .onAppear {
            setupNotifications()
            setupNotificationDelegate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    checkFirstTimeUser()
                }
            }
        }
        }
    }
    
    private func checkFirstTimeUser() {
        // Check if user has seen welcome screen
        if let preferences = userPreferences.first {
            if !preferences.hasSeenWelcomeScreen {
                showWelcome = true
            } else {
                isActive = true
            }
        } else {
            // No preferences exist yet, show welcome screen
            showWelcome = true
        }
    }
    
    private func transitionToMainApp() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showWelcome = false
            isActive = true
        }
    }
    
    private func setupNotifications() {
        // Set up notification categories for actions
        let createRecapAction = UNNotificationAction(
            identifier: "CREATE_RECAP",
            title: "Start Reflection",
            options: [.foreground]
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Me Later",
            options: []
        )
        
        let weeklyRecapCategory = UNNotificationCategory(
            identifier: "WEEKLY_RECAP",
            actions: [createRecapAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([weeklyRecapCategory])
        
        // Request notification permission on app launch
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted on app launch")
                } else {
                    print("Notification permission denied on app launch")
                    if let error = error {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    private func setupNotificationDelegate() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
}

#Preview {
    LoadingView()
        .modelContainer(for: [JournalEntry.self, UserPreferences.self], inMemory: true)
}

