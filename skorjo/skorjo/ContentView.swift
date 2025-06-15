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

                // Placeholder center tab
                Text("")
                    .tabItem {
                        Text("") // Empty to reserve space
                    }
                    .tag(1)

                BrowseEntriesView()
                    .tabItem {
                        Label("Browse", systemImage: "magnifyingglass")
                    }
                    .tag(2)
            }

            // Floating Add Button centered over tab bar
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showEntryTypeSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 42, height: 42)

                            Image(systemName: "plus")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 0)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, UIScreen.main.bounds.width / 2 - 28)
            }
        }
        .sheet(isPresented: $showEntryTypeSheet) {
            EntryTypeSelectorView(
                showActivityForm: $showActivityForm,
                showReflectionForm: $showReflectionForm,
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
