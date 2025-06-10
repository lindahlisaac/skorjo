//
//  BrowseEntriesView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData

struct BrowseEntriesView: View {
    @Query(sort: \JournalEntry.date, order: .reverse) private var allEntries: [JournalEntry]
    @State private var selectedType: ActivityType? = nil
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var endDate: Date = .now

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Filter by Activity Type")) {
                        Picker("Activity Type", selection: $selectedType) {
                            Text("All").tag(ActivityType?.none)
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type as ActivityType?)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    Section(header: Text("Filter by Date Range")) {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        DatePicker("End", selection: $endDate, displayedComponents: .date)
                    }
                }

                List(filteredEntries) { entry in
                    NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                        VStack(alignment: .leading) {
                            Text(entry.title)
                                .font(.headline)
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Browse Entries")
        }
    }

    var filteredEntries: [JournalEntry] {
        allEntries.filter { entry in
            let matchesType = selectedType == nil || entry.activityType == selectedType
            let matchesDate = entry.date >= startDate && entry.date <= endDate
            return matchesType && matchesDate
        }
    }
}
