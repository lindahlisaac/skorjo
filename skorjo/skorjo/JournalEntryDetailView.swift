//
//  JournalEntryDetailView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/9/25.
//

import SwiftUI
import SwiftData
import Combine
import Charts

struct JournalEntryDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    var entry: JournalEntry

    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedText: String = ""
    @State private var editedStravaLink: String = ""
    @State private var editedActivityType: ActivityType = .run
    @State private var editedDate: Date = .now
    @State private var editedFeeling: Int = 5
    @FocusState private var focusedField: Field?
    @State private var showEditSheet = false
    @State private var showAddCheckInSheet = false
    @State private var newCheckInDate = Date()
    @State private var newCheckInPain = 5
    @State private var newCheckInNotes = ""
    @State private var expandedCheckInIndices: Set<Int> = []
    @State private var isResolved = false

    enum Field: Hashable {
        case title, text, stravaLink
    }

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    private func aggregateDataByMonth(checkIns: [InjuryCheckIn]) -> [(date: Date, pain: Double)] {
        let calendar = Calendar.current
        let groupedData = Dictionary(grouping: checkIns) { checkIn in
            calendar.startOfMonth(for: checkIn.date)
        }
        
        return groupedData.map { (date, checkIns) in
            let averagePain = Double(checkIns.map { $0.pain }.reduce(0, +)) / Double(checkIns.count)
            return (date: date, pain: averagePain)
        }.sorted { $0.date < $1.date }
    }
    
    private func shouldAggregateByMonth(checkIns: [InjuryCheckIn]) -> Bool {
        guard let firstDate = checkIns.first?.date,
              let lastDate = checkIns.last?.date else { return false }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: firstDate, to: lastDate)
        return (components.month ?? 0) >= 2 // Aggregate if span is 2 or more months
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                    Spacer()
                    Label(entry.activityType.rawValue, systemImage: icon(for: entry.activityType))
                        .font(.caption)
                        .padding(8)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.bottom, 4)
                .listRowSeparator(.hidden)
                Text(entry.title)
                    .font(.headline)
                if entry.activityType == .injury, let side = entry.injurySide {
                    HStack {
                        Text("Side: ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(side.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                if entry.activityType != .injury {
                    Text(entry.text)
                        .padding(.top, 4)
                }
                if let link = entry.stravaLink,
                   let url = URL(string: link), !link.isEmpty {
                    Link("View on Strava", destination: url)
                        .padding(.top, 4)
                }
                if entry.activityType != .reflection, let feeling = entry.feeling {
                    HStack {
                        Spacer()
                        Text("Feeling: \(feeling)")
                            .font(.caption)
                            .foregroundColor(Color(red: 0.784, green: 0.635, blue: 0.784))
                        Spacer()
                    }
                }
                
                if entry.activityType == .golf, let score = entry.golfScore {
                    HStack {
                        Spacer()
                        Text("Score: \(score)")
                            .font(.caption)
                            .foregroundColor(score <= 72 ? .green : score <= 80 ? .orange : .red)
                        Spacer()
                    }
                }
                
                if entry.activityType == .injury, let checkIns = entry.injuryCheckIns {
                    Section(header: Text("Pain Level Over Time").foregroundColor(lilac)) {
                        let sortedCheckIns = checkIns.sorted(by: { $0.date < $1.date })
                        let shouldAggregate = shouldAggregateByMonth(checkIns: sortedCheckIns)
                        let dataPoints = shouldAggregate ? aggregateDataByMonth(checkIns: sortedCheckIns) : sortedCheckIns.map { (date: $0.date, pain: Double($0.pain)) }
                        
                        Chart {
                            ForEach(dataPoints, id: \.date) { point in
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Pain", point.pain)
                                )
                                .foregroundStyle(lilac)
                                .interpolationMethod(.catmullRom)
                                
                                PointMark(
                                    x: .value("Date", point.date),
                                    y: .value("Pain", point.pain)
                                )
                                .foregroundStyle(lilac)
                            }
                        }
                        .frame(height: 200)
                        .chartYScale(domain: 0...10)
                        .chartYAxis {
                            AxisMarks(values: .automatic(desiredCount: 5))
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 5)) { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        Text(date.formatted(date: .numeric, time: .omitted))
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header:
                        HStack {
                            Text("Check-Ins").foregroundColor(lilac)
                            Spacer()
                            Button(action: {
                                newCheckInDate = Date()
                                newCheckInPain = 5
                                newCheckInNotes = ""
                                isResolved = false
                                showAddCheckInSheet = true
                            }) {
                                Label("Add Check-In", systemImage: "plus.circle")
                                    .labelStyle(IconOnlyLabelStyle())
                            }
                            .foregroundColor(lilac)
                        }
                    ) {
                        let sortedCheckIns = checkIns.sorted(by: { $0.date > $1.date })
                        ForEach(sortedCheckIns.indices, id: \.self) { idx in
                            let checkIn = sortedCheckIns[idx]
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(checkIn.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                    Spacer()
                                    if checkIn.pain == 0 {
                                        Text("Resolved")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    } else {
                                        Text("Pain: \(checkIn.pain)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Button(action: {
                                        if expandedCheckInIndices.contains(idx) {
                                            expandedCheckInIndices.remove(idx)
                                        } else {
                                            expandedCheckInIndices.insert(idx)
                                        }
                                    }) {
                                        Image(systemName: expandedCheckInIndices.contains(idx) ? "chevron.down" : "chevron.right")
                                            .foregroundColor(lilac)
                                    }
                                }
                                if expandedCheckInIndices.contains(idx), let notes = checkIn.notes, !notes.isEmpty {
                                    Text(notes)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .padding(.top, 2)
                                }
                            }
                        }
                        .onDelete { offsets in
                            deleteCheckIns(at: offsets, from: sortedCheckIns)
                        }
                    }
                }

                if entry.activityType == .injury, let details = entry.injuryDetails, !details.isEmpty {
                    Section(header: Text("Injury Details").foregroundColor(lilac)) {
                        Text(details)
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEditSheet = true
                }
                .foregroundColor(lilac)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if entry.activityType == .reflection {
                ReflectionEntryFormView(entryToEdit: entry)
            } else if entry.activityType == .injury {
                InjuryEntryFormView(entryToEdit: entry)
            } else if entry.activityType == .weeklyRecap {
                WeeklyRecapEntryFormView(entryToEdit: entry)
            } else {
                ActivityEntryFormView(entryToEdit: entry)
            }
        }
        .sheet(isPresented: $showAddCheckInSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Date").foregroundColor(lilac)) {
                        DatePicker("Check-In Date", selection: $newCheckInDate, displayedComponents: .date)
                            .accentColor(lilac)
                    }
                    Section(header: Text("Pain Level").foregroundColor(lilac)) {
                        Toggle("Resolved", isOn: $isResolved)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                        Slider(value: Binding(
                            get: { Double(isResolved ? 0 : newCheckInPain) },
                            set: { newCheckInPain = Int($0) }
                        ), in: 1...10, step: 1)
                        .accentColor(lilac)
                        .disabled(isResolved)
                        HStack {
                            Text("1")
                            Spacer()
                            Text("10")
                        }
                        if isResolved {
                            Text("Pain: 0 (Resolved)")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Pain: \(newCheckInPain)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Section(header: Text("Notes (optional)").foregroundColor(lilac)) {
                        TextEditor(text: $newCheckInNotes)
                            .frame(height: 60)
                            .accentColor(lilac)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lilac.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.vertical, 4)
                    }
                    Section {
                        Button("Add Check-In") {
                            var updatedCheckIns = entry.injuryCheckIns ?? []
                            updatedCheckIns.append(InjuryCheckIn(date: newCheckInDate, pain: isResolved ? 0 : newCheckInPain, notes: newCheckInNotes.trimmingCharacters(in: .whitespacesAndNewlines)))
                            entry.injuryCheckIns = updatedCheckIns
                            try? context.save()
                            showAddCheckInSheet = false
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(lilac)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.headline)
                    }
                }
                .navigationTitle("Add Check-In")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddCheckInSheet = false
                        }
                    }
                }
            }
        }
    }

    private func loadValues() {
        editedTitle = entry.title
        editedText = entry.text
        editedStravaLink = entry.stravaLink ?? ""
        editedActivityType = entry.activityType
        editedDate = entry.date
        editedFeeling = entry.feeling ?? 5
    }

    private func saveChanges() {
        entry.title = editedTitle
        entry.text = editedText
        entry.stravaLink = editedStravaLink.isEmpty ? nil : editedStravaLink
        entry.activityType = editedActivityType
        entry.date = editedDate
        entry.feeling = editedActivityType != .reflection ? editedFeeling : nil
        do {
            try context.save()
            isEditing = false
        } catch {
            print("Error saving edits: \(error)")
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
        case .yoga: return "figure.mind.and.body"
        case .golf: return "figure.golf"
        case .reflection: return "brain"
        case .other: return "bolt"
        case .weeklyRecap: return "calendar.badge.clock"
        case .injury: return "cross.case"
        }
    }

    private func hideKeyboard() {
        // Implementation of hideKeyboard function
    }

    private func deleteCheckIns(at offsets: IndexSet, from sortedCheckIns: [InjuryCheckIn]) {
        guard var currentCheckIns = entry.injuryCheckIns else { return }
        let sorted = currentCheckIns.sorted(by: { $0.date > $1.date })
        for index in offsets {
            if let originalIndex = currentCheckIns.firstIndex(of: sorted[index]) {
                currentCheckIns.remove(at: originalIndex)
            }
        }
        entry.injuryCheckIns = currentCheckIns
        try? context.save()
    }
}

// Add Calendar extension for month start date
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
