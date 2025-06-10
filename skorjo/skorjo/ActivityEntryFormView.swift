//
//  ActivityEntryFormView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/10/25.
//

import SwiftUI
import SwiftData

struct ActivityEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var stravaLink: String = ""
    @State private var activityType: ActivityType = .run

    var body: some View {
        Form {
            Section(header: Text("Date")) {
                DatePicker("Entry Date", selection: $date, displayedComponents: .date)
            }

            Section(header: Text("Title")) {
                TextField("Title", text: $title)
            }

            Section(header: Text("Details")) {
                TextEditor(text: $text)
                    .frame(height: 120)
            }

            Section(header: Text("Strava Link")) {
                TextField("https://www.strava.com/...", text: $stravaLink)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            Section(header: Text("Activity Type")) {
                Picker("Select Type", selection: $activityType) {
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }

            Section {
                Button("Add Entry") {
                    addEntry()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || text.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("New Activity")
    }

    private func addEntry() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let prefixedTitle = formatter.string(from: date) + " - " + title.trimmingCharacters(in: .whitespaces)

        let entry = JournalEntry(
            date: date,
            title: prefixedTitle,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            stravaLink: stravaLink.isEmpty ? nil : stravaLink,
            activityType: activityType
        )

        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
