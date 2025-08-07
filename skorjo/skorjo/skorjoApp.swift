//
//  skorjoApp.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData

@main
struct SkorjoApp: App {
    var body: some Scene {
        WindowGroup {
            LoadingView()
                .font(.system(size: 17, design: .rounded)) // 👈 Applies to all child views
        }
        .modelContainer(for: [JournalEntry.self, UserPreferences.self])
    }
}
