import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ExportView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    
    @State private var selectedFormat: ExportFormat = .json
    @State private var selectedDateRange: DateRange = .all
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var endDate: Date = .now
    @State private var selectedActivityTypes: Set<ActivityType> = Set(ActivityType.allCases)
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var shareSheet: ShareSheetItem?
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case text = "Text"
        case csv = "CSV"
    }
    
    enum DateRange: String, CaseIterable {
        case all = "All Time"
        case lastMonth = "Last Month"
        case lastThreeMonths = "Last 3 Months"
        case custom = "Custom Range"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Export Format")) {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Date Range")) {
                    Picker("Range", selection: $selectedDateRange) {
                        ForEach(DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    
                    if selectedDateRange == .custom {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
                
                Section(header: Text("Activity Types")) {
                    ForEach(ActivityType.allCases, id: \.self) { type in
                        Toggle(type.rawValue, isOn: Binding(
                            get: { selectedActivityTypes.contains(type) },
                            set: { isSelected in
                                if isSelected {
                                    selectedActivityTypes.insert(type)
                                } else {
                                    selectedActivityTypes.remove(type)
                                }
                            }
                        ))
                    }
                }
                
                Section {
                    Button(action: prepareAndExport) {
                        HStack {
                            Spacer()
                            Text("Export")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Export Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Export Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(item: $shareSheet) { sheet in
            ShareSheet(activityItems: [sheet.text], fileName: sheet.fileName, fileType: sheet.fileType)
        }
    }
    
    private var filteredEntries: [JournalEntry] {
        entries.filter { entry in
            let matchesType = selectedActivityTypes.contains(entry.activityType)
            let matchesDate: Bool
            
            switch selectedDateRange {
            case .all:
                matchesDate = true
            case .lastMonth:
                let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
                matchesDate = entry.date >= oneMonthAgo
            case .lastThreeMonths:
                let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: .now) ?? .now
                matchesDate = entry.date >= threeMonthsAgo
            case .custom:
                matchesDate = entry.date >= startDate && entry.date <= endDate
            }
            
            return matchesType && matchesDate
        }
    }
    
    private func prepareAndExport() {
        let filtered = filteredEntries
        
        guard !filtered.isEmpty else {
            errorMessage = "No entries found matching your selected criteria."
            showError = true
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        var text = ""
        var fileName = "skorjo_export_\(Date().timeIntervalSince1970)"
        var fileType: String? = nil
        
        switch selectedFormat {
        case .json:
            text = exportAsJSON(entries: filtered)
            fileName += ".json"
            fileType = "public.json"
        case .text:
            text = ""
            for entry in filtered {
                text += "\(entry.title)\n"
                text += "Date: \(formatter.string(from: entry.date))\n"
                text += "Activity Type: \(entry.activityType.rawValue)\n\n"
                text += "\(entry.text)\n\n"
                if let stravaLink = entry.stravaLink {
                    text += "Strava Link: \(stravaLink)\n\n"
                }
                text += "-------------------\n\n"
            }
            fileName += ".txt"
            fileType = "public.plain-text"
        case .csv:
            // CSV header
            text = "id,date,title,text,stravaLink,activityType\n"
            let csvFormatter = DateFormatter()
            csvFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            for entry in filtered {
                let id = csvEscape(entry.id.uuidString)
                let date = csvEscape(csvFormatter.string(from: entry.date))
                let title = csvEscape(entry.title)
                let entryText = csvEscape(entry.text)
                let strava = csvEscape(entry.stravaLink ?? "")
                let activity = csvEscape(entry.activityType.rawValue)
                text += "\(id),\(date),\(title),\(entryText),\(strava),\(activity)\n"
            }
            fileName += ".csv"
            fileType = "public.comma-separated-values-text"
        }
        
        guard !text.isEmpty else {
            errorMessage = "Failed to generate export text."
            showError = true
            return
        }
        
        shareSheet = ShareSheetItem(text: text, fileName: fileName, fileType: fileType)
    }
    
    private func exportAsJSON(entries: [JournalEntry]) -> String {
        let dateFormatter = ISO8601DateFormatter()
        
        let exportData = ExportData(
            exportDate: Date(),
            totalEntries: entries.count,
            dateRange: selectedDateRange.rawValue,
            activityTypes: Array(selectedActivityTypes).map { $0.rawValue },
            entries: entries.map { entry in
                                    EntryData(
                        id: entry.id.uuidString,
                        date: entry.date,
                        title: entry.title,
                        text: entry.text,
                        stravaLink: entry.stravaLink,
                        activityType: entry.activityType.rawValue,
                        feeling: entry.feeling,
                        endDate: entry.endDate,
                        weekFeeling: entry.weekFeeling,
                        injuryName: entry.injuryName,
                        injuryStartDate: entry.injuryStartDate,
                        injuryCheckIns: entry.injuryCheckIns,
                        injuryDetails: entry.injuryDetails,
                        injurySide: entry.injurySide?.rawValue,
                        golfScore: entry.golfScore,
                        milestoneTitle: entry.milestoneTitle,
                        achievementValue: entry.achievementValue,
                        milestoneDate: entry.milestoneDate,
                        milestoneNotes: entry.milestoneNotes,
                        photos: entry.photos.isEmpty ? nil : entry.photos.compactMap { photo in
                            guard let uiImage = photo.load(),
                                  let imageData = JournalPhoto.processImage(uiImage),
                                  let base64String = imageData.base64EncodedString().nilIfEmpty else {
                                return nil
                            }
                            return PhotoData(
                                id: photo.id.uuidString,
                                caption: photo.caption,
                                imageData: base64String
                            )
                        }
                    )
            }
        )
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(exportData)
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    
    private func csvEscape(_ value: String) -> String {
        var escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            escaped = "\"\(escaped)\""
        }
        return escaped
    }
}

// MARK: - JSON Export Data Structures

struct ExportData: Codable {
    let exportDate: Date
    let totalEntries: Int
    let dateRange: String
    let activityTypes: [String]
    let entries: [EntryData]
}

struct EntryData: Codable {
    let id: String
    let date: Date
    let title: String
    let text: String
    let stravaLink: String?
    let activityType: String
    let feeling: Int?
    let endDate: Date?
    let weekFeeling: Int?
    let injuryName: String?
    let injuryStartDate: Date?
    let injuryCheckIns: [InjuryCheckIn]?
    let injuryDetails: String?
    let injurySide: String?
    let golfScore: Int?
    let milestoneTitle: String?
    let achievementValue: String?
    let milestoneDate: Date?
    let milestoneNotes: String?
    let photos: [PhotoData]?
}

struct PhotoData: Codable {
    let id: String
    let caption: String?
    let imageData: String // Base64 encoded image data
}

struct ShareSheetItem: Identifiable {
    let id = UUID()
    let text: String
    let fileName: String
    let fileType: String?
}

extension String {
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let fileName: String?
    let fileType: String?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        var items = activityItems
        // If exporting as a file, create a temp file and share the URL
        if let fileName, let fileType, let text = activityItems.first as? String {
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)
            do {
                try text.write(to: fileURL, atomically: true, encoding: .utf8)
                items = [fileURL]
            } catch {
                // fallback: share as plain text
            }
        }
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks
        ]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 