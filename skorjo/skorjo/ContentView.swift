//
//  ContentView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]

    @State private var newEntryText = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Write a new journal entry...", text: $newEntryText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...5)

                    Button(action: addEntry) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newEntryText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding()

                List(entries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(entry.text)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Skorjo Journal")
        }
    }

    private func addEntry() {
        let trimmed = newEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let entry = JournalEntry(text: trimmed)
        context.insert(entry)
        try? context.save()

        newEntryText = ""
    }
}
