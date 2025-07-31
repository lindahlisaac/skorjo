import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \JournalEntry.date, order: .reverse) private var existingEntries: [JournalEntry]
    
    @State private var showDocumentPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @State private var importedCount = 0
    @State private var duplicateCount = 0
    @State private var isImporting = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Import Journal Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Select a JSON file exported from Skorjo to import your journal entries.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Import Options
                VStack(spacing: 16) {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Select JSON File")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isImporting)
                    
                    if isImporting {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Importing...")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Import Info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Import Information")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(title: "Current Entries", value: "\(existingEntries.count)")
                        InfoRow(title: "Supported Format", value: "JSON (Skorjo export)")
                        InfoRow(title: "Duplicate Handling", value: "Skip duplicates by ID")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showDocumentPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .alert("Import Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Import Complete", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Successfully imported \(importedCount) entries. Skipped \(duplicateCount) duplicates.")
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                errorMessage = "No file selected."
                showError = true
                return
            }
            
            importFromURL(url)
            
        case .failure(let error):
            errorMessage = "Failed to access file: \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func importFromURL(_ url: URL) {
        isImporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                DispatchQueue.main.async {
                    errorMessage = "Permission denied to access the selected file."
                    showError = true
                    isImporting = false
                }
                return
            }
            
            defer {
                // Stop accessing the security-scoped resource
                url.stopAccessingSecurityScopedResource()
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let exportData = try decoder.decode(ExportData.self, from: data)
                
                DispatchQueue.main.async {
                    processImportData(exportData)
                }
                
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to parse JSON file: \(error.localizedDescription)"
                    showError = true
                    isImporting = false
                }
            }
        }
    }
    
    private func processImportData(_ exportData: ExportData) {
        var imported = 0
        var duplicates = 0
        
        // Create a set of existing IDs for quick lookup
        let existingIds = Set(existingEntries.map { $0.id.uuidString })
        
        for entryData in exportData.entries {
            // Check if entry already exists
            if existingIds.contains(entryData.id) {
                duplicates += 1
                continue
            }
            
            // Create new entry
            let newEntry = JournalEntry(
                id: UUID(uuidString: entryData.id) ?? UUID(),
                date: entryData.date,
                title: entryData.title,
                text: entryData.text,
                stravaLink: entryData.stravaLink,
                activityType: ActivityType(rawValue: entryData.activityType) ?? .other,
                feeling: entryData.feeling,
                endDate: entryData.endDate,
                weekFeeling: entryData.weekFeeling,
                injuryName: entryData.injuryName,
                injuryStartDate: entryData.injuryStartDate,
                injuryCheckIns: entryData.injuryCheckIns,
                injuryDetails: entryData.injuryDetails,
                injurySide: InjurySide(rawValue: entryData.injurySide ?? "") ?? .na
            )
            
            context.insert(newEntry)
            imported += 1
        }
        
        // Save context
        do {
            try context.save()
            importedCount = imported
            duplicateCount = duplicates
            showSuccess = true
        } catch {
            errorMessage = "Failed to save imported entries: \(error.localizedDescription)"
            showError = true
        }
        
        isImporting = false
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Preview
#Preview {
    ImportView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
} 