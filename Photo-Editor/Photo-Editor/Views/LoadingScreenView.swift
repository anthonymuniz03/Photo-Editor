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
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
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
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
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
