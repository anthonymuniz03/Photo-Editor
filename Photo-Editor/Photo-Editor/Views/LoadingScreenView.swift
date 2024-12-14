//
//  LoadingScreenView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/10/24.
//

import SwiftUI

struct LoadingScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Solid background to cover everything
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .opacity(isAnimating ? 0.5 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text("Loading...")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 16)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingScreenView()
}
