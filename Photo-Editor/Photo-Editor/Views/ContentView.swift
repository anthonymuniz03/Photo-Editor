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

    var body: some View {
        VStack {
            TabView {
                HomeScreenView(
                    recentImages: $recentImages,
                    trashedImages: $trashedImages
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
        }
    }
}


#Preview {
    ContentView()
}
