import SwiftUI
import SwiftData
import Combine

struct WeeklyRecapEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var endDate: Date = .now
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var tag: String = ""
    @State private var weekFeeling: Int = 5
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title, text, tag
    }

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var startDate: Date {
        Calendar.current.date(byAdding: .day, value: -6, to: endDate) ?? endDate
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
            Form {
                Section(header: Text("End Date").foregroundColor(lilac)) {
                    DatePicker("End of Week", selection: $endDate, displayedComponents: .date)
                        .accentColor(lilac)
                }
                Section(header: Text("Start Date").foregroundColor(lilac)) {
                    Text(startDate.formatted(date: .abbreviated, time: .omitted))
                        .foregroundColor(.secondary)
                }
                Section(header: Text("Title").foregroundColor(lilac)) {
                    TextField("Title", text: $title)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .title)
                }
                Section(header: Text("Weekly Recap").foregroundColor(lilac)) {
                    TextEditor(text: $text)
                        .frame(height: 120)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .text)
                }
                Section(header: Text("Tag").foregroundColor(lilac)) {
                    TextField("Optional tag (e.g. wins, challenges)", text: $tag)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .tag)
                }
                Section(header: Text("How did this week feel?").foregroundColor(lilac)) {
                    VStack(alignment: .leading) {
                        Slider(value: Binding(
                            get: { Double(weekFeeling) },
                            set: { weekFeeling = Int($0) }
                        ), in: 1...10, step: 1)
                        .accentColor(lilac)
                        HStack {
                            Text("1")
                            Spacer()
                            Text("10")
                        }
                        Text("Feeling: \(weekFeeling)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Section {
                    Button("Add Weekly Recap") {
                        addWeeklyRecap()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(lilac)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.headline)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("New Weekly Recap")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
        }
    }

    private func addWeeklyRecap() {
        let fullText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        let taggedText = fullText + (finalTag.isEmpty ? "" : "\n\n#\(finalTag)")
        let entry = JournalEntry(
            date: startDate,
            title: title.trimmingCharacters(in: .whitespaces),
            text: taggedText,
            stravaLink: nil,
            activityType: .weeklyRecap,
            feeling: nil,
            endDate: endDate,
            weekFeeling: weekFeeling
        )
        context.insert(entry)
        try? context.save()
        dismiss()
    }
} 