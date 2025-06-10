//
//  ReflectionEntryFormView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/10/25.
//

import SwiftUI
import SwiftData

struct ReflectionEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var tag: String = ""

    var body: some View {
        Form {
            Section(header: Text("Date")) {
                DatePicker("Reflection Date", selection: $date, displayedComponents: .date)
            }

            Section(header: Text("Title")) {
                TextField("Title", text: $title)
            }

            Section(header: Text("Reflection")) {
                TextEditor(text: $text)
                    .frame(height: 120)
            }

            Section(header: Text("Tag")) {
                TextField("Optional tag (e.g. mindset, gratitude)", text: $tag)
            }

            Section {
                Button("Add Reflection") {
                    addReflection()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || text.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle("New Reflection")
    }

    private func addReflection() {
        let fullText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        let taggedText = fullText + (finalTag.isEmpty ? "" : "\n\n#\(finalTag)")

        let entry = JournalEntry(
            date: date,
            title: title.trimmingCharacters(in: .whitespaces),
            text: taggedText,
            stravaLink: nil,
            activityType: .reflection
        )

        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
