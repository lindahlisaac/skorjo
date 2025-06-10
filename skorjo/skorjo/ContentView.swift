import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse, animation: .default) private var entries: [JournalEntry]

    @State private var title: String = ""
    @State private var text = ""
    @State private var stravaLink = ""
    @State private var activityType: ActivityType = .run
    @State private var selectedDate: Date = .now

    @State private var entryToEdit: JournalEntry? = nil
    @State private var editedText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)

                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Write your entry...", text: $text, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)

                    TextField("Strava Link (optional)", text: $stravaLink)
                        .textFieldStyle(.roundedBorder)

                    Picker("Activity", selection: $activityType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)

                Button(action: addEntry) {
                    Label("Add Entry", systemImage: "plus.circle.fill")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || text.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)

                List {
                    ForEach(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(entry.activityType.rawValue)
                                    .font(.caption)
                                    .padding(4)
                                    .background(.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))

                                Spacer()
                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Text(entry.title).bold()
                            Text(entry.text)

                            if let link = entry.stravaLink, !link.isEmpty {
                                Link("View on Strava", destination: URL(string: link)!)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            entryToEdit = entry
                            editedText = entry.text
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
            .navigationTitle("Skorjo Journal")
            .sheet(item: $entryToEdit) { entry in
                NavigationView {
                    VStack {
                        TextEditor(text: $editedText)
                            .padding()
                            .navigationTitle("Edit Entry")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") {
                                        entryToEdit = nil
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Save") {
                                        updateEntry(entry)
                                    }
                                }
                            }
                    }
                }
            }
        }
    }

    private func addEntry() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, !trimmedTitle.isEmpty else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let formattedDatePrefix = formatter.string(from: selectedDate) + " - "

        let entry = JournalEntry(
            date: selectedDate,
            title: formattedDatePrefix + trimmedTitle,
            text: trimmedText,
            stravaLink: stravaLink.isEmpty ? nil : stravaLink,
            activityType: activityType
        )
        context.insert(entry)

        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        title = ""
        text = ""
        stravaLink = ""
        activityType = .run
        selectedDate = .now
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            context.delete(entries[index])
        }
        try? context.save()
    }

    private func updateEntry(_ entry: JournalEntry) {
        let trimmed = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            entry.text = trimmed
            try? context.save()
        }
        entryToEdit = nil
    }
}
