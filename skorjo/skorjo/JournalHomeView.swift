import SwiftUI
import SwiftData

struct JournalHomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \JournalEntry.date, order: .reverse, animation: .default) private var entries: [JournalEntry]

    var body: some View {
        NavigationView {
            List {
                ForEach(entries) { entry in
                    NavigationLink(destination: JournalEntryDetailView(entry: entry)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Label(entry.activityType.rawValue, systemImage: icon(for: entry.activityType))
                                    .font(.caption)
                                    .padding(6)
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                Spacer()

                                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Text(entry.title)
                                .font(.headline)

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
                }
                .onDelete(perform: deleteEntries)
            }
            .listStyle(.plain)
            .navigationTitle("Skorjo Journal")
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
        case .reflection: return "brain"
        case .other: return "bolt"
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            context.delete(entries[index])
        }
        try? context.save()
    }
}
