//
//  BrowseEntriesView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData

struct BrowseEntriesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse) private var allEntries: [JournalEntry]
    
    @State private var selectedActivityType: ActivityType? = nil
    @State private var searchText = ""
    @State private var selectedEntry: JournalEntry?
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var filteredEntries: [JournalEntry] {
        var entries = allEntries
        
        if let selectedType = selectedActivityType {
            entries = entries.filter { $0.activityType == selectedType }
        }
        
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.text.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return entries
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Section
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search entries...", text: $searchText)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // Activity Type Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedActivityType == nil,
                                action: { selectedActivityType = nil }
                            )
                            
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue,
                                    isSelected: selectedActivityType == type,
                                    action: { selectedActivityType = type }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
                
                // Results Count
                HStack {
                    Text("\(filteredEntries.count) entries")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Entries List
                List {
                    ForEach(filteredEntries) { entry in
                        Button(action: {
                            selectedEntry = entry
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Label(entry.activityType.rawValue, systemImage: icon(for: entry.activityType))
                                        .font(.caption)
                                        .padding(6)
                                        .background(lilac.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    Spacer()
                                    
                                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(entry.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(entry.text)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.primary.opacity(0.12), radius: 6, x: 0, y: 3)
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Browse Entries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry)
            }
        }
    }
    
    private func icon(for type: ActivityType) -> String {
        switch type {
        case .run: return "figure.run"
        case .walk: return "figure.walk"
        case .hike: return "figure.hiking"
        case .bike: return "bicycle"
        case .swim: return "drop"
        case .lift: return "dumbbell"
        case .yoga: return "figure.mind.and.body"
        case .golf: return "figure.golf"
        case .milestone: return "trophy.fill"
        case .reflection: return "brain"
        case .other: return "bolt"
        case .weeklyRecap: return "calendar.badge.clock"
        case .injury: return "cross.case"
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? lilac : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

#Preview {
    BrowseEntriesView()
        .modelContainer(for: [JournalEntry.self, UserPreferences.self])
}
