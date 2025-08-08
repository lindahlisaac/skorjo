import SwiftUI
import SwiftData
import Combine

struct InjuryEntryFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var entryToEdit: JournalEntry? = nil

    @State private var injuryStartDate: Date = .now
    @State private var injuryName: String = ""
    @State private var checkIns: [InjuryCheckIn] = [InjuryCheckIn(date: .now, pain: 5)]
    @FocusState private var focusedField: Field?
    @State private var injuryDetails: String = ""
    @State private var injurySide: InjurySide = .na

    enum Field: Hashable {
        case name
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
                Section(header: Text("Start Date").foregroundColor(lilac)) {
                    DatePicker("Injury Start Date", selection: $injuryStartDate, displayedComponents: .date)
                        .accentColor(lilac)
                }
                Section(header: Text("Injury Name").foregroundColor(lilac)) {
                    TextField("e.g. Sprained Ankle", text: $injuryName)
                        .accentColor(lilac)
                        .focused($focusedField, equals: .name)
                }
                Section(header: Text("Side").foregroundColor(lilac)) {
                    Picker("Side", selection: $injurySide) {
                        ForEach(InjurySide.allCases, id: \.self) { side in
                            Text(side.rawValue).tag(side)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section(header: Text("Details").foregroundColor(lilac)) {
                    ZStack(alignment: .topLeading) {
                        if injuryDetails.isEmpty {
                            Text("How did the injury occur?")
                                .foregroundColor(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.horizontal, 5)
                        }
                        TextEditor(text: $injuryDetails)
                            .frame(height: 100)
                            .accentColor(lilac)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lilac.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.vertical, 4)
                    }
                }
                Section(header: Text("Check-Ins").foregroundColor(lilac)) {
                    ForEach(checkIns.indices, id: \.self) { idx in
                        VStack(alignment: .leading, spacing: 8) {
                            DatePicker("Date", selection: $checkIns[idx].date, displayedComponents: .date)
                                .accentColor(lilac)
                            HStack {
                                Text("Pain:")
                                Slider(value: Binding(
                                    get: { Double(checkIns[idx].pain) },
                                    set: { checkIns[idx].pain = Int($0) }
                                ), in: 1...10, step: 1)
                                .accentColor(lilac)
                                Text("\(checkIns[idx].pain)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            if checkIns.count > 1 {
                                Button(role: .destructive) {
                                    checkIns.remove(at: idx)
                                } label: {
                                    Label("Remove Check-In", systemImage: "minus.circle")
                                }
                                .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    Button {
                        checkIns.append(InjuryCheckIn(date: .now, pain: 5))
                    } label: {
                        Label("Add Check-In", systemImage: "plus.circle")
                    }
                    .foregroundColor(lilac)
                }
                Section {
                    Button(isEditing ? "Save Changes" : "Add Injury") {
                        saveOrAddInjury()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(lilac)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.headline)
                    .disabled(injuryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle(isEditing ? "Edit Injury" : "New Injury")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Save Changes" : "Add Injury") {
                        saveOrAddInjury()
                    }
                    .disabled(injuryName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { hideKeyboard() }
                }
            }
            .onAppear {
                if let entry = entryToEdit {
                    injuryStartDate = entry.injuryStartDate ?? .now
                    injuryName = entry.injuryName ?? ""
                    checkIns = entry.injuryCheckIns ?? [InjuryCheckIn(date: .now, pain: 5)]
                    injuryDetails = entry.injuryDetails ?? ""
                    injurySide = entry.injurySide ?? .na
                }
                }
            }
        }
    }

    private func saveOrAddInjury() {
        if let entry = entryToEdit {
            entry.injuryStartDate = injuryStartDate
            entry.injuryName = injuryName.trimmingCharacters(in: .whitespaces)
            entry.injuryCheckIns = checkIns
            entry.date = injuryStartDate
            entry.title = injuryName.trimmingCharacters(in: .whitespaces)
            entry.activityType = .injury
            entry.injuryDetails = injuryDetails.trimmingCharacters(in: .whitespacesAndNewlines)
            entry.injurySide = injurySide
            try? context.save()
            dismiss()
        } else {
            let entry = JournalEntry(
                date: injuryStartDate,
                title: injuryName.trimmingCharacters(in: .whitespaces),
                text: "",
                stravaLink: nil,
                activityType: .injury,
                feeling: nil,
                endDate: nil,
                weekFeeling: nil,
                injuryName: injuryName.trimmingCharacters(in: .whitespaces),
                injuryStartDate: injuryStartDate,
                injuryCheckIns: checkIns,
                injuryDetails: injuryDetails.trimmingCharacters(in: .whitespacesAndNewlines),
                injurySide: injurySide
            )
            context.insert(entry)
            try? context.save()
            dismiss()
        }
    }
} 