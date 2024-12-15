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
    @Binding var cloudImageURLs: [String]
    @Binding var trashedCloudImageURLs: [String]
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
                
                TrashView(
                    trashedImages: $trashedImages,
                    recentImages: $recentImages,
                    trashedCloudImageURLs: $trashedCloudImageURLs
                )
                .tabItem {
                    Label("Trash", systemImage: "trash")
                }
                
                CloudinaryImageView()
                    .tabItem {
                        Label("Cloud", systemImage: "cloud")
                    }

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }

            if isLoading {
                LoadingScreenView()
                    .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    ContentView(
        cloudImageURLs: .constant([]),
        trashedCloudImageURLs: .constant([])
    )
}
