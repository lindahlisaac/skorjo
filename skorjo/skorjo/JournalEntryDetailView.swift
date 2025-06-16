//
//  JournalEntryDetailView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData
import Combine

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
    @State private var editedFeeling: Int = 5
    @FocusState private var focusedField: Field?
    @State private var showEditSheet = false

    enum Field: Hashable {
        case title, text, stravaLink
    }

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var body: some View {
        Form {
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
                if entry.activityType != .reflection, let feeling = entry.feeling {
                    HStack {
                        Spacer()
                        Text("Feeling: \(feeling)")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.784, green: 0.635, blue: 0.784))
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditSheet = true
                }
                .foregroundColor(Color(red: 0.784, green: 0.635, blue: 0.784))
            }
        }
        .sheet(isPresented: $showEditSheet) {
            ActivityEntryFormView(entryToEdit: entry)
        }
    }

    private func loadValues() {
        editedTitle = entry.title
        editedText = entry.text
        editedStravaLink = entry.stravaLink ?? ""
        editedActivityType = entry.activityType
        editedDate = entry.date
        editedFeeling = entry.feeling ?? 5
    }

    private func saveChanges() {
        entry.title = editedTitle
        entry.text = editedText
        entry.stravaLink = editedStravaLink.isEmpty ? nil : editedStravaLink
        entry.activityType = editedActivityType
        entry.date = editedDate
        entry.feeling = editedActivityType != .reflection ? editedFeeling : nil
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
        case .reflection: return "brain"
        case .other: return "bolt"
        }
    }

    private func hideKeyboard() {
        // Implementation of hideKeyboard function
    }
}
