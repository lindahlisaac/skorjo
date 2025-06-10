//
//  ContentView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showEntryTypeSheet = false
    @State private var showActivityForm = false
    @State private var showReflectionForm = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                JournalHomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                Color.clear
                    .tabItem {
                        Image(systemName: "plus.circle")
                    }
                    .tag(1)

                BrowseEntriesView()
                    .tabItem {
                        Label("Browse", systemImage: "magnifyingglass")
                    }
                    .tag(2)
            }

            // Floating "+" Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showEntryTypeSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.accentColor)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .offset(y: -20)
                    Spacer()
                }
            }
            .padding(.bottom, 0)
        }
        .sheet(isPresented: $showEntryTypeSheet) {
            EntryTypeSelectorView(
                onSelectActivity: {
                    showEntryTypeSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showActivityForm = true
                    }
                },
                onSelectReflection: {
                    showEntryTypeSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showReflectionForm = true
                    }
                }
            )
        }
        .sheet(isPresented: $showActivityForm) {
            ActivityEntryFormView()
        }
        .sheet(isPresented: $showReflectionForm) {
            ReflectionEntryFormView()
        }
    }
}
