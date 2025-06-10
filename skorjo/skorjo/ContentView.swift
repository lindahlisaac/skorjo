//
//  ContentView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            JournalHomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            BrowseEntriesView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}
