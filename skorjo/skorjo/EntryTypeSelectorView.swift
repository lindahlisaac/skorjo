//
//  EntryTypeSelectorView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/10/25.
//

import SwiftUI
import SwiftData

struct EntryTypeSelectorView: View {
    @Environment(\.modelContext) private var context
    @Query private var userPreferences: [UserPreferences]
    
    @Binding var showActivityForm: Bool
    @Binding var showReflectionForm: Bool
    @Binding var showMilestoneForm: Bool
    var onSelectActivity: () -> Void
    var onSelectReflection: () -> Void
    var onSelectWeeklyRecap: () -> Void
    var onSelectInjury: () -> Void
    var onSelectMilestone: () -> Void
    
    @State private var isReordering = false
    @State private var draggedItem: String?
    @GestureState private var isDragging = false

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    private let entryTypes = [
        EntryType(name: "Activity", icon: "figure.run", action: "onSelectActivity"),
        EntryType(name: "Reflection", icon: "brain.head.profile", action: "onSelectReflection"),
        EntryType(name: "Weekly Recap", icon: "calendar.badge.clock", action: "onSelectWeeklyRecap"),
        EntryType(name: "Injury", icon: "cross.case", action: "onSelectInjury"),
        EntryType(name: "Milestone", icon: "trophy.fill", action: "onSelectMilestone")
    ]
    
    private var currentOrder: [String] {
        userPreferences.first?.entryTypeOrder ?? ["Activity", "Reflection", "Weekly Recap", "Injury", "Milestone"]
    }
    
    private var orderedEntryTypes: [EntryType] {
        let order = currentOrder
        return order.compactMap { typeName in
            entryTypes.first { $0.name == typeName }
        }
    }

    var body: some View {
        let buttonSize = UIScreen.main.bounds.width * 0.4
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        VStack(spacing: 24) {
            HStack {
                Text("What would you like to add?")
                    .font(.headline)
                    .foregroundColor(lilac)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isReordering.toggle()
                        if !isReordering {
                            draggedItem = nil
                        }
                    }
                }) {
                    Text(isReordering ? "Done" : "Reorder")
                        .font(.subheadline)
                        .foregroundColor(lilac)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(orderedEntryTypes, id: \.name) { entryType in
                    EntryTypeButton(
                        entryType: entryType,
                        buttonSize: buttonSize,
                        isReordering: isReordering,
                        draggedItem: $draggedItem,
                        isDragging: _isDragging,
                        onTap: handleEntryTypeTap,
                        onDrag: handleDrag,
                        onDrop: handleDrop
                    )
                }
            }
            Spacer()
        }
        .padding()
    }
    
    private func handleEntryTypeTap(_ entryType: EntryType) {
        if !isReordering {
            switch entryType.action {
            case "onSelectActivity":
                onSelectActivity()
            case "onSelectReflection":
                onSelectReflection()
            case "onSelectWeeklyRecap":
                onSelectWeeklyRecap()
            case "onSelectInjury":
                onSelectInjury()
            case "onSelectMilestone":
                onSelectMilestone()
            default:
                break
            }
        }
    }
    
    private func handleDrag(_ entryType: EntryType) -> NSItemProvider {
        draggedItem = entryType.name
        return NSItemProvider(object: entryType.name as NSString)
    }
    
    private func handleDrop(_ entryType: EntryType, _ providers: [NSItemProvider]) -> Bool {
        guard let draggedName = draggedItem,
              let draggedIndex = currentOrder.firstIndex(of: draggedName),
              let targetIndex = currentOrder.firstIndex(of: entryType.name),
              draggedIndex != targetIndex else {
            draggedItem = nil
            return false
        }
        
        var newOrder = currentOrder
        let item = newOrder.remove(at: draggedIndex)
        newOrder.insert(item, at: targetIndex)
        
        if let preferences = userPreferences.first {
            preferences.updateEntryTypeOrder(newOrder)
            try? context.save()
        }
        
        draggedItem = nil
        return true
    }
}

struct EntryType {
    let name: String
    let icon: String
    let action: String
}

struct EntryTypeButton: View {
    let entryType: EntryType
    let buttonSize: CGFloat
    let isReordering: Bool
    @Binding var draggedItem: String?
    let isDragging: GestureState<Bool>
    let onTap: (EntryType) -> Void
    let onDrag: (EntryType) -> NSItemProvider
    let onDrop: (EntryType, [NSItemProvider]) -> Bool
    
    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: entryType.icon)
                .font(.system(size: 32, weight: .medium))
            Text(entryType.name)
                .font(.headline)
        }
        .foregroundColor(lilac)
        .frame(width: buttonSize, height: buttonSize)
        .background(lilac.opacity(0.2))
        .cornerRadius(16)
        .scaleEffect(draggedItem == entryType.name ? 1.1 : 1.0)
        .shadow(color: draggedItem == entryType.name ? lilac.opacity(0.5) : Color.clear, radius: 8)
        .onTapGesture {
            onTap(entryType)
        }
        .onDrag {
            onDrag(entryType)
        }
        .onDrop(of: [.text], isTargeted: nil) { providers in
            onDrop(entryType, providers)
        }
        .gesture(
            DragGesture()
                .onEnded { _ in
                    if draggedItem == entryType.name {
                        draggedItem = nil
                    }
                }
        )
    }
}
