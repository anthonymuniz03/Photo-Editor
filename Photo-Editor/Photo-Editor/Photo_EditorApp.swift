//
//  Photo_EditorApp.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

@main
struct Photo_EditorApp: App {
    @State private var isSplashScreenVisible = true
    @State private var isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
    @State private var cloudImageURLs: [String] = []
    @State private var trashedCloudImageURLs: [String] = []

    private let photoController = PhotoController()

    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 61/255, green: 168/255, blue: 116/255, alpha: 0.5)
        let normalTabItemColor = UIColor(red: 0/255, green: 100/255, blue: 0/255, alpha: 1.0)
        let selectedTabItemColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        appearance.stackedLayoutAppearance.normal.iconColor = normalTabItemColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalTabItemColor]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedTabItemColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedTabItemColor]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            if isSplashScreenVisible {
                SplashScreenView(
                    isSplashScreenVisible: $isSplashScreenVisible,
                    cloudImageURLs: $cloudImageURLs,
                    trashedCloudImageURLs: $trashedCloudImageURLs
                )
                .onAppear {
                    Task {
                        let startTime = Date()
                        await loadInitialCloudImages()
                        let elapsedTime = Date().timeIntervalSince(startTime)
                        
                        let minimumDisplayTime: TimeInterval = 5.0
                        if elapsedTime < minimumDisplayTime {
                            try? await Task.sleep(nanoseconds: UInt64((minimumDisplayTime - elapsedTime) * 1_000_000_000))
                        }

                        isSplashScreenVisible = false
                    }
                }
            } else if !isOnboardingComplete {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            } else {
                ContentView(
                    cloudImageURLs: $cloudImageURLs,
                    trashedCloudImageURLs: $trashedCloudImageURLs
                )
            }
        }
    }

    func loadInitialCloudImages() async {
        let loadedCloudImages = photoController.loadCloudImageURLs(page: 1, pageSize: 50)
        let loadedTrashedCloudImages = photoController.loadTrashedCloudImageURLs()

        await MainActor.run {
            cloudImageURLs = loadedCloudImages
            trashedCloudImageURLs = loadedTrashedCloudImages
        }
    }
}
