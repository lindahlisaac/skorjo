//
//  LoadingView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/12/25.
//

import SwiftUI
import SwiftData

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
}

#Preview {
    LoadingView()
        .modelContainer(for: [JournalEntry.self, UserPreferences.self], inMemory: true)
}

