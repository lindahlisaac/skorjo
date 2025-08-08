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

    var entryToEdit: JournalEntry? = nil

    @State private var date: Date = .now
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var stravaLink: String = ""
    @State private var activityType: ActivityType = .run
    @State private var feeling: Int = 5
    @State private var golfScore: Int = 72
    @State private var photos: [JournalPhoto] = []

    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case title, text, stravaLink
    }

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var isEditing: Bool { entryToEdit != nil }

    var body: some View {
        NavigationStack {
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
                
                if activityType == .golf {
                    Section(header: Text("Golf Score").foregroundColor(lilac)) {
                        HStack {
                            Text("Score")
                            Spacer()
                            Stepper(value: $golfScore, in: 50...150) {
                                Text("\(golfScore)")
                                    .font(.headline)
                                    .foregroundColor(golfScore <= 72 ? .green : golfScore <= 80 ? .orange : .red)
                            }
                        }
                    }
                }
                
                Section(header: Text("Photos").foregroundColor(lilac)) {
                    PhotoPickerView(photos: $photos, maxPhotos: 5, lilac: lilac)
                }

                Section {
                    Button(isEditing ? "Save Changes" : "Add Entry") {
                        saveOrAddEntry()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(lilac)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.headline)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle(isEditing ? "Edit Activity" : "New Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Save Changes" : "Add Entry") {
                        saveOrAddEntry()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
            .onAppear {
                if let entry = entryToEdit {
                    date = entry.date
                    title = entry.title
                    text = entry.text
                    stravaLink = entry.stravaLink ?? ""
                    activityType = entry.activityType
                    feeling = entry.feeling ?? 5
                    photos = entry.photos ?? []
                }
                }
            }
        }
    }

    private func saveOrAddEntry() {
        if let entry = entryToEdit {
            // Edit existing
            entry.date = date
            entry.title = title
            entry.text = text
            entry.stravaLink = stravaLink.isEmpty ? nil : stravaLink
            entry.activityType = activityType
            entry.feeling = activityType != .reflection ? feeling : nil
            entry.photos = photos
            try? context.save()
            dismiss()
        } else {
            // Add new
            let entry = JournalEntry(
                date: date,
                title: title.trimmingCharacters(in: .whitespaces),
                text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                stravaLink: stravaLink.isEmpty ? nil : stravaLink,
                activityType: activityType,
                feeling: activityType != .reflection ? feeling : nil,
                golfScore: activityType == .golf ? golfScore : nil,
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
