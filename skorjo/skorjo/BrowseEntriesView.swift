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

    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? .now
    @State private var endDate: Date = Date()
    @State private var selectedActivity: ActivityType? = nil
    @State private var searchText: String = ""

    var filteredEntries: [JournalEntry] {
        allEntries.filter { entry in
            entry.date >= startDate &&
            entry.date <= endDate &&
            (selectedActivity == nil || entry.activityType == selectedActivity) &&
            (searchText.isEmpty || entry.title.localizedCaseInsensitiveContains(searchText) || entry.text.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Date Range")) {
                        DatePicker("Start", selection: $startDate, displayedComponents: .date)
                        DatePicker("End", selection: $endDate, displayedComponents: .date)
                    }

                    Section(header: Text("Activity Type")) {
                        Picker("Activity", selection: $selectedActivity) {
                            Text("All").tag(ActivityType?.none)
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(Optional(type))
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section(header: Text("Search")) {
                        TextField("Search text...", text: $searchText)
                    }
                }

                List {
                    ForEach(filteredEntries) { entry in
                        NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(entry.title)
                                    .font(.headline)
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(entry.text)
                                    .font(.body)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    if filteredEntries.isEmpty {
                        Text("No entries match your filters.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Browse Entries")
        }
    }
}
