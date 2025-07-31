import SwiftUI
import SwiftData

struct MilestoneEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var achievementValue = ""
    @State private var date = Date()
    @State private var milestoneDate = Date()
    @State private var notes = ""
    @State private var feeling: Int = 10
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case title, achievementValue, notes
    }
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { hideKeyboard() }
            Form {
                Section(header: Text("Achievement Details")) {
                    TextField("What did you achieve? (Ex: 'First Marathon')", text: $title)
                        .focused($focusedField, equals: .title)
                    
                    TextField("Achievement value (Ex: '3:45:23', '1 rep')", text: $achievementValue)
                        .focused($focusedField, equals: .achievementValue)
                    
                    DatePicker("When did this happen?", selection: $milestoneDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("How do you feel?")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            ForEach(1...10, id: \.self) { number in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        feeling = number
                                    }
                                }) {
                                    Text("\(number)")
                                        .font(.system(size: 14, weight: .medium))
                                        .frame(width: 32, height: 32)
                                        .background(feeling == number ? lilac : Color.gray.opacity(0.2))
                                        .foregroundColor(feeling == number ? .white : .primary)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 8)
                        Text("Feeling: \(feeling)/10")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                    }
                }
                
                Section(header: Text("The Story")) {
                    TextField("Tell us about this milestone... What led to it? How did it feel? What does it mean to you?", text: $notes, axis: .vertical)
                        .lineLimit(5...10)
                        .focused($focusedField, equals: .notes)
                }
                
                Section(header: Text("Journal Entry Date")) {
                    DatePicker("When are you recording this?", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Add Entry") {
                        saveEntry()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(lilac)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.headline)
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveEntry() {
        guard !title.isEmpty else {
            alertMessage = "Please enter what you achieved."
            showAlert = true
            return
        }
        
        let entry = JournalEntry(
            date: date,
            title: title,
            text: notes,
            activityType: .milestone,
            feeling: feeling,
            milestoneTitle: title,
            achievementValue: achievementValue.isEmpty ? nil : achievementValue,
            milestoneDate: milestoneDate,
            milestoneNotes: notes.isEmpty ? nil : notes
        )
        
        context.insert(entry)
        
        do {
            try context.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save milestone: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func hideKeyboard() {
        focusedField = nil
    }
}

#Preview {
    MilestoneEntryFormView()
        .modelContainer(for: JournalEntry.self, inMemory: true)
} 