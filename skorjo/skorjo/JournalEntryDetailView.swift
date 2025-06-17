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

    @Bindable var entry: JournalEntry

    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedText: String = ""
    @State private var editedStravaLink: String = ""
    @State private var editedActivityType: ActivityType = .run
    @State private var editedDate: Date = .now
    @State private var editedFeeling: Int = 5
    @FocusState private var focusedField: Field?
    @State private var showEditSheet = false

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
                        .chartYScale(domain: 1...10)
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
                    
                    Section(header: Text("Check-Ins").foregroundColor(lilac)) {
                        ForEach(checkIns.sorted(by: { $0.date > $1.date }), id: \.self) { checkIn in
                            HStack {
                                Text(checkIn.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.subheadline)
                                Spacer()
                                Text("Pain: \(checkIn.pain)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
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
        case .reflection: return "brain"
        case .other: return "bolt"
        case .weeklyRecap: return "calendar.badge.clock"
        case .injury: return "cross.case"
        }
    }

    private func hideKeyboard() {
        // Implementation of hideKeyboard function
    }
}

// Add Calendar extension for month start date
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
