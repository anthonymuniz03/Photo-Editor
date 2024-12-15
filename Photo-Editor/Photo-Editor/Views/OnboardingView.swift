//
//  OnboardingView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/15/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                VStack(spacing: 16) {
                    Text("Welcome to PhotoLab!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("""
                    It's a simple app that I hope you enjoy.

                    You tap the big button to pick a picture,
                    spin it around or make it orange or blue
                    and save!

                    You can save directly to your device or
                    save it here on the app. If you ever lose it,
                    don't worry! The Gallery next door will
                    have it waiting for you too!

                    Enjoy!
                    """)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.3))
                    )
                    .padding(.horizontal, 20)
                }

                Spacer()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, 20)

                Button(action: {
                    UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
                    isOnboardingComplete = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 34 / 255, green: 139 / 255, blue: 34 / 255))
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
