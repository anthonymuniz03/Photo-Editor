//
//  ContentView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var recentImages: [UIImage] = []
    @State private var trashedImages: [UIImage] = []
    @State private var isLoading = false

    var body: some View {
        ZStack {
            TabView {
                HomeScreenView(
                    recentImages: $recentImages,
                    trashedImages: $trashedImages,
                    isLoading: $isLoading
                )
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                GalleryView()
                    .tabItem {
                        Label("Gallery", systemImage: "photo")
                    }

                TrashView(
                    trashedImages: $trashedImages,
                    recentImages: $recentImages
                )
                .tabItem {
                    Label("Trash", systemImage: "trash")
                }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }

            // Full-screen loading overlay
            if isLoading {
                LoadingScreenView()
                    .ignoresSafeArea(.all) // Ensures it covers the entire screen
            }
        }
    }
}

#Preview {
    ContentView()
}
