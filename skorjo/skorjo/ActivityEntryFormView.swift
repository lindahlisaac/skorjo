//
//  ActivityEntryFormView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/10/25.
//

import SwiftUI
import SwiftData
import Combine

struct ActivityEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var stravaLink: String = ""
    @State private var activityType: ActivityType = .run
    @State private var feeling: Int = 5

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title, text, stravaLink
    }

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
            Form {
                Section(header: Text("Date").foregroundColor(lilac)) {
                    DatePicker("Entry Date", selection: $date, displayedComponents: .date)
                        .accentColor(lilac)
                }

                Section(header: Text("Title").foregroundColor(lilac)) {
                    TextField("Title", text: $title)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .title)
                }

                Section(header: Text("Details").foregroundColor(lilac)) {
                    TextEditor(text: $text)
                        .frame(height: 120)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .text)
                }

                Section(header: Text("Strava Link").foregroundColor(lilac)) {
                    TextField("https://www.strava.com/...", text: $stravaLink)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .stravaLink)
                }

                Section(header: Text("Activity Type").foregroundColor(lilac)) {
                    Picker("Select Type", selection: $activityType) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .accentColor(lilac)
                }

                if activityType != .reflection {
                    Section(header: Text("How do you feel?").foregroundColor(lilac)) {
                        VStack(alignment: .leading) {
                            Slider(value: Binding(
                                get: { Double(feeling) },
                                set: { feeling = Int($0) }
                            ), in: 1...10, step: 1)
                            .accentColor(lilac)
                            HStack {
                                Text("1")
                                Spacer()
                                Text("10")
                            }
                            Text("Feeling: \(feeling)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Button("Add Entry") {
                        addEntry()
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
            .navigationTitle("New Activity")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
        }
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
            activityType: activityType,
            feeling: activityType != .reflection ? feeling : nil
        )

        context.insert(entry)
        try? context.save()
        dismiss()
    }
}
