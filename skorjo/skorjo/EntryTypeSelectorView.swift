//
//  EntryTypeSelectorView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/10/25.
//

import SwiftUI

struct EntryTypeSelectorView: View {
    @Environment(\.dismiss) var dismiss

    let onSelectActivity: () -> Void
    let onSelectReflection: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                Text("What would you like to add?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 40)

                Button {
                    onSelectActivity()
                } label: {
                    Label("Activity Entry", systemImage: "figure.run")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Button {
                    onSelectReflection()
                } label: {
                    Label("Reflection", systemImage: "pencil.and.outline")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
