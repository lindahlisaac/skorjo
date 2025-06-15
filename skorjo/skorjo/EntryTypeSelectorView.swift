//
//  EntryTypeSelectorView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/10/25.
//

import SwiftUI

struct EntryTypeSelectorView: View {
    @Binding var showActivityForm: Bool
    @Binding var showReflectionForm: Bool
    var onSelectActivity: () -> Void
    var onSelectReflection: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("What would you like to add?")
                .font(.headline)

            Button(action: onSelectActivity) {
                Label("Activity Entry", systemImage: "figure.run")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(8)
            }

            Button(action: onSelectReflection) {
                Label("Reflection", systemImage: "brain.head.profile")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
}
