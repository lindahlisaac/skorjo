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
    @State private var showWeeklyRecapForm = false
    @State private var showInjuryForm = false
    @State private var showMilestoneForm = false
    @State private var selectedHomeEntry: JournalEntry? = nil

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                JournalHomeView(selectedEntry: $selectedHomeEntry)
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
            .onChange(of: selectedTab) { _, newValue in
                if newValue == 0 {
                    selectedHomeEntry = nil
                }
            }
            .tint(Color(red: 0.784, green: 0.635, blue: 0.784)) // lilac accent

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
                                .fill(Color(red: 0.784, green: 0.635, blue: 0.784)) // lilac accent
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
                showMilestoneForm: $showMilestoneForm,
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
                },
                onSelectWeeklyRecap: {
                    showEntryTypeSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showWeeklyRecapForm = true
                    }
                },
                onSelectInjury: {
                    showEntryTypeSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showInjuryForm = true
                    }
                },

                onSelectMilestone: {
                    showEntryTypeSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showMilestoneForm = true
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
        .sheet(isPresented: $showWeeklyRecapForm) {
            WeeklyRecapEntryFormView()
        }
        .sheet(isPresented: $showInjuryForm) {
            InjuryEntryFormView()
        }
        .sheet(isPresented: $showMilestoneForm) {
            MilestoneEntryFormView()
        }
    }
}
