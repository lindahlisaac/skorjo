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
            ContentView()
        }
        .modelContainer(for: JournalEntry.self)
    }
}

