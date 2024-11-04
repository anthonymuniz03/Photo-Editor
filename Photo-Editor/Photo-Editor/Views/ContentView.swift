//
//  ContentView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        VStack {
            TabView {
                HomeScreenView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                GalleryView()
                    .tabItem {
                        Label("Gallery", systemImage: "photo")
                    }
                
                TrashView()
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
