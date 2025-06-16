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
    var onSelectWeeklyRecap: () -> Void

    private let lilac = Color(red: 0.784, green: 0.635, blue: 0.784)

    var body: some View {
        let buttonSize = UIScreen.main.bounds.width * 0.4
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        VStack(spacing: 24) {
            Text("What would you like to add?")
                .font(.headline)
                .foregroundColor(lilac)
            LazyVGrid(columns: columns, spacing: 24) {
                Button(action: onSelectActivity) {
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 32, weight: .medium))
                        Text("Activity")
                            .font(.headline)
                    }
                    .foregroundColor(lilac)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(lilac.opacity(0.2))
                    .cornerRadius(16)
                }
                Button(action: onSelectReflection) {
                    VStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 32, weight: .medium))
                        Text("Reflection")
                            .font(.headline)
                    }
                    .foregroundColor(lilac)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(lilac.opacity(0.2))
                    .cornerRadius(16)
                }
                Button(action: onSelectWeeklyRecap) {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 32, weight: .medium))
                        Text("Weekly Recap")
                            .font(.headline)
                    }
                    .foregroundColor(lilac)
                    .frame(width: buttonSize, height: buttonSize)
                    .background(lilac.opacity(0.2))
                    .cornerRadius(16)
                }
            }
            Spacer()
        }
        .padding()
    }
}
