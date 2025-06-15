//
//  LoadingView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/12/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isActive = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                Spacer()

                Text("Skorjo")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 20)

                Text("Not every step needs to be shared.\nNot every feeling needs a like.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(colorScheme == .dark ? Color(red: 0.784, green: 0.635, blue: 0.784) : .primary)
                    .padding(.horizontal)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    LoadingView()
}
