//
//  SettingsView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Image("backedit")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(
                                Capsule()
                                    .fill(Color.green)
                            )
                        Spacer()
                    }
                    .padding([.top, .leading], 20)

                    Spacer()

                    Button(action: {
                        showResetAlert = true
                    }) {
                        Text("Reset App Data")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.red)
                            )
                            .padding(.horizontal, 40)
                    }

                    Spacer()
                }
            }
            .alert("Reset App Data", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAppData()
                }
            } message: {
                Text("Are you sure you want to erase all app data? This action cannot be undone.")
            }
        }
    }

    func resetAppData() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()

        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")

        clearDocumentsDirectory()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let onboardingView = OnboardingView(isOnboardingComplete: .constant(false))
            window.rootViewController = UIHostingController(rootView: onboardingView)
            window.makeKeyAndVisible()
        }
    }

    func clearDocumentsDirectory() {
        let fileManager = FileManager.default
        if let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
                let filePaths = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                for filePath in filePaths {
                    try fileManager.removeItem(at: filePath)
                }
            } catch {
                print("Error clearing Documents directory: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
}
