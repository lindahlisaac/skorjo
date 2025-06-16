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

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var body: some View {
        VStack(spacing: 24) {
            Text("What would you like to add?")
                .font(.headline)
                .foregroundColor(lilac)

            Button(action: onSelectActivity) {
                Label("Activity Entry", systemImage: "figure.run")
                    .foregroundColor(lilac)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(lilac.opacity(0.2))
                    .cornerRadius(8)
            }

            Button(action: onSelectReflection) {
                Label("Reflection", systemImage: "brain.head.profile")
                    .foregroundColor(lilac)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(lilac.opacity(0.2))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
    }
}
