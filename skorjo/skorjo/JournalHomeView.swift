import SwiftUI
import SwiftData

struct JournalHomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse, animation: .default) private var entries: [JournalEntry]

    @State private var title: String = ""
    @State private var text = ""
    @State private var stravaLink = ""
    @State private var activityType: ActivityType = .run
    @State private var selectedDate: Date = .now

    @State private var showEntryForm = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // Toggle Entry Form
                    Button(action: {
                        withAnimation {
                            showEntryForm.toggle()
                        }
                    }) {
                        Label(showEntryForm ? "Hide Entry Form" : "Add New Entry", systemImage: showEntryForm ? "chevron.up.circle.fill" : "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    .padding(.top)

                    // Entry Form
                    if showEntryForm {
                        VStack(alignment: .leading, spacing: 12) {
                            DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)

                            TextField("Title", text: $title)
                                .textFieldStyle(.roundedBorder)

                            TextEditor(text: $text)
                                .frame(minHeight: 100)
                                .padding(6)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)

                            TextField("Strava Link (optional)", text: $stravaLink)
                                .textFieldStyle(.roundedBorder)

                            Picker("Activity", selection: $activityType) {
                                ForEach(ActivityType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)

                            Button(action: addEntry) {
                                Label("Add Entry", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || text.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.primary.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Entries List
                    List {
                        ForEach(entries) { entry in
                            NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Label(entry.activityType.rawValue, systemImage: icon(for: entry.activityType))
                                            .font(.caption)
                                            .padding(6)
                                            .background(Color.accentColor.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 6))

                                        Spacer()

                                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }

                                    Text(entry.title)
                                        .font(.headline)

                                    Text(entry.text)
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    if let link = entry.stravaLink, !link.isEmpty {
                                        Link(destination: URL(string: link)!) {
                                            Label("View on Strava", systemImage: "link")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.primary.opacity(0.12), radius: 6, x: 0, y: 3)
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Skorjo Journal")
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

        withAnimation {
            showEntryForm = false
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            context.delete(entries[index])
        }
        try? context.save()
    }
}
