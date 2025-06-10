//
//  JournalEntryDetailView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData

struct JournalEntryDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var entry: JournalEntry

    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedText: String = ""
    @State private var editedStravaLink: String = ""
    @State private var editedActivityType: ActivityType = .run
    @State private var editedDate: Date = .now

    var body: some View {
        Form {
            if isEditing {
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $editedDate, displayedComponents: .date)
                }

                Section(header: Text("Title")) {
                    TextField("Title", text: $editedTitle)
                }

                Section(header: Text("Entry")) {
                    TextEditor(text: $editedText)
                        .frame(minHeight: 120)
                }

                Section(header: Text("Strava Link")) {
                    TextField("Strava Link", text: $editedStravaLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }

                Section(header: Text("Activity Type")) {
                    Picker("Activity", selection: $editedActivityType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            } else {
                Section {
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)

                    Text(entry.title)
                        .font(.headline)

                    Text(entry.text)
                        .padding(.top, 4)

                    if let link = entry.stravaLink,
                       let url = URL(string: link), !link.isEmpty {
                        Link("View on Strava", destination: url)
                            .padding(.top, 4)
                    }

                    HStack {
                        Spacer()
                        Label(entry.activityType.rawValue, systemImage: icon(for: entry.activityType))
                            .font(.caption)
                            .padding(8)
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
            } else {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        loadValues()
                        isEditing = true
                    }
                }
            }
        }
        .onAppear {
            loadValues()
        }
    }

    private func loadValues() {
        editedTitle = entry.title
        editedText = entry.text
        editedStravaLink = entry.stravaLink ?? ""
        editedActivityType = entry.activityType
        editedDate = entry.date
    }

    private func saveChanges() {
        entry.title = editedTitle
        entry.text = editedText
        entry.stravaLink = editedStravaLink.isEmpty ? nil : editedStravaLink
        entry.activityType = editedActivityType
        entry.date = editedDate

        do {
            try context.save()
            isEditing = false
        } catch {
            print("Error saving edits: \(error)")
        }
    }

    private func icon(for type: ActivityType) -> String {
        switch type {
        case .run: return "figure.run"
        case .walk: return "figure.walk"
        case .hike: return "figure.hiking"
        case .bike: return "bicycle"
        case .swim: return "drop"
        case .lift: return "weightlifting"
        case .other: return "bolt"
        }
    }
}
