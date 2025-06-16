//
//  ReflectionEntryFormView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/10/25.
//

import SwiftUI
import SwiftData
import Combine

struct ReflectionEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var tag: String = ""

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title, text, tag
    }

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
            Form {
                Section(header: Text("Date").foregroundColor(lilac)) {
                    DatePicker("Reflection Date", selection: $date, displayedComponents: .date)
                        .accentColor(lilac)
                }

                Section(header: Text("Title").foregroundColor(lilac)) {
                    TextField("Title", text: $title)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .title)
                }

                Section(header: Text("Reflection").foregroundColor(lilac)) {
                    TextEditor(text: $text)
                        .frame(height: 120)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .text)
                }

                Section(header: Text("Tag").foregroundColor(lilac)) {
                    TextField("Optional tag (e.g. mindset, gratitude)", text: $tag)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .tag)
                }

                Section {
                    Button("Add Reflection") {
                        addReflection()
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
            .navigationTitle("New Reflection")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
        }
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
