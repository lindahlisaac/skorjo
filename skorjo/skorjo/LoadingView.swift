//
//  LoadingView.swift
//  skorjo
//
//  Created by Isaac Lindahl on 6/12/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 40) {
                Text("Skorjo")
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(.white)

                VStack(spacing: 10) {
                    Text("Not every step")
                    Text("needs to be shared.")
                    Text("Not every feeling")
                    Text("needs a like.")
                }
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            ContentView()
        }
    }
}
