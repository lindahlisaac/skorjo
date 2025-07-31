import SwiftUI
import SwiftData

struct JournalHomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse, animation: .default) private var entries: [JournalEntry]
    @State private var showExportSheet = false
    @State private var showImportSheet = false
    @Binding var selectedEntry: JournalEntry?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // What's New Card
                WhatsNewCard()
                    .padding(.top, 8)
                
                List {
                    ForEach(sortedEntries) { entry in
                        Button(action: {
                            selectedEntry = entry
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Label(entry.activityType.rawValue, systemImage: icon(for: entry.activityType))
                                        .font(.caption)
                                        .padding(6)
                                        .background(Color.accentColor.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))

                                    Spacer()

                                    if entry.activityType == .weeklyRecap, let endDate = entry.endDate {
                                        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: endDate) ?? endDate
                                        Text("\(startDate.formatted(date: .abbreviated, time: .omitted)) - \(endDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    } else if entry.activityType == .injury, let injuryStart = entry.injuryStartDate {
                                        Text("Started: \(injuryStart.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    } else {
                                        Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                if entry.activityType == .injury {
                                    Text(entry.injuryName ?? "Injury")
                                        .font(.headline)
                                    if let checkIn = entry.injuryCheckIns?.sorted(by: { $0.date > $1.date }).first {
                                        Text("Last Check-In: \(checkIn.date.formatted(date: .abbreviated, time: .omitted)), Pain: \(checkIn.pain)")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.784, green: 0.635, blue: 0.784))
                                    }
                                                            } else if entry.activityType == .golf {
                                Text(entry.title)
                                    .font(.headline)
                                if let score = entry.golfScore {
                                    Text("Score: \(score)")
                                        .font(.caption)
                                        .foregroundColor(score <= 72 ? .green : score <= 80 ? .orange : .red)
                                }
                            } else if entry.activityType == .milestone {
                                Text(entry.milestoneTitle ?? entry.title)
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                if let value = entry.achievementValue {
                                    Text(value)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                        .fontWeight(.medium)
                                }
                            } else {
                                    Text(entry.title)
                                        .font(.headline)

                                    if entry.activityType == .weeklyRecap, let weekFeeling = entry.weekFeeling {
                                        Text("Week Feeling: \(weekFeeling)")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.784, green: 0.635, blue: 0.784))
                                    }
                                }

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
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteEntries)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Skorjo Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showExportSheet = true }) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        Button(action: { showImportSheet = true }) {
                            Label("Import", systemImage: "square.and.arrow.down")
                        }
                        Divider()
                        Button(action: resetWelcomeScreen) {
                            Label("Reset Welcome Screen", systemImage: "arrow.clockwise")
                        }
                        Button(action: resetWhatsNew) {
                            Label("Show What's New", systemImage: "sparkles")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showExportSheet) {
                ExportView()
            }
            .sheet(isPresented: $showImportSheet) {
                ImportView()
            }
            .navigationDestination(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry)
            }
        }
    }

    private var sortedEntries: [JournalEntry] {
        entries.sorted {
            let lhsDate = $0.activityType == .weeklyRecap ? $0.endDate ?? $0.date : $0.date
            let rhsDate = $1.activityType == .weeklyRecap ? $1.endDate ?? $1.date : $1.date
            return lhsDate > rhsDate
        }
    }

    private func icon(for type: ActivityType) -> String {
        switch type {
        case .run: return "figure.run"
        case .walk: return "figure.walk"
        case .hike: return "figure.hiking"
        case .bike: return "bicycle"
        case .swim: return "drop"
        case .lift: return "dumbbell"
        case .yoga: return "figure.mind.and.body"
        case .golf: return "figure.golf"
        case .milestone: return "trophy.fill"
        case .reflection: return "brain"
        case .other: return "bolt"
        case .weeklyRecap: return "calendar.badge.clock"
        case .injury: return "cross.case"
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entryToDelete = sortedEntries[index]
            if let originalIndex = entries.firstIndex(where: { $0.id == entryToDelete.id }) {
                context.delete(entries[originalIndex])
            }
        }
        try? context.save()
    }
    
    private func resetWelcomeScreen() {
        let fetchDescriptor = FetchDescriptor<UserPreferences>()
        if let preferences = try? context.fetch(fetchDescriptor).first {
            preferences.hasSeenWelcomeScreen = false
            try? context.save()
            print("Welcome screen reset successfully!")
        }
    }
    
    private func resetWhatsNew() {
        let fetchDescriptor = FetchDescriptor<UserPreferences>()
        if let preferences = try? context.fetch(fetchDescriptor).first {
            preferences.lastSeenAppVersion = "1.0.0" // Reset to previous version
            try? context.save()
            print("What's New card reset successfully!")
        }
    }
}
