import SwiftUI
import SwiftData
import Combine

struct WeeklyRecapEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: JournalEntry? = nil

    @State private var endDate: Date = .now
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var tag: String = ""
    @State private var weekFeeling: Int = 5
    @State private var photos: [JournalPhoto] = []
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title, text, tag
    }

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var isEditing: Bool { entryToEdit != nil }

    var startDate: Date {
        Calendar.current.date(byAdding: .day, value: -6, to: endDate) ?? endDate
    }

    var body: some View {
        NavigationStack {
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
                
                Section(header: Text("Photos").foregroundColor(lilac)) {
                    PhotoPickerView(photos: $photos, maxPhotos: 5, lilac: lilac)
                }
                
                Section {
                    Button(isEditing ? "Save Changes" : "Add Weekly Recap") {
                        saveOrAddWeeklyRecap()
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
            .navigationTitle(isEditing ? "Edit Weekly Recap" : "New Weekly Recap")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Save Changes" : "Add Weekly Recap") {
                        saveOrAddWeeklyRecap()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
            .onAppear {
                if let entry = entryToEdit {
                    endDate = entry.endDate ?? .now
                    title = entry.title
                    // Parse tag from text if present
                    if let tagRange = entry.text.range(of: "\n\n#") {
                        text = String(entry.text[..<tagRange.lowerBound])
                        tag = String(entry.text[tagRange.upperBound...])
                    } else {
                        text = entry.text
                        tag = ""
                    }
                    weekFeeling = entry.weekFeeling ?? 5
                    photos = entry.photos
                }
                }
            }
        }
    }

    private func saveOrAddWeeklyRecap() {
        let fullText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTag = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        let taggedText = fullText + (finalTag.isEmpty ? "" : "\n\n#\(finalTag)")
        if let entry = entryToEdit {
            entry.endDate = endDate
            entry.title = title.trimmingCharacters(in: .whitespaces)
            entry.text = taggedText
            entry.activityType = .weeklyRecap
            entry.date = startDate
            entry.weekFeeling = weekFeeling
            entry.photos = photos
            try? context.save()
            dismiss()
        } else {
            let entry = JournalEntry(
                date: startDate,
                title: title.trimmingCharacters(in: .whitespaces),
                text: taggedText,
                stravaLink: nil,
                activityType: .weeklyRecap,
                feeling: nil,
                endDate: endDate,
                weekFeeling: weekFeeling,
                photos: photos
            )
            
            // Insert photos into context first
            for photo in photos {
                context.insert(photo)
            }
            context.insert(entry)
            try? context.save()
            dismiss()
        }
    }
} 