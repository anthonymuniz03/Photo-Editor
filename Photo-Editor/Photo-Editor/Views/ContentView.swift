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
                
                Text("Gallery")
                    .tabItem {
                        Label("Gallery", systemImage: "photo")
                    }
                
                Text("Trash")
                    .tabItem {
                        Label("Trash", systemImage: "trash")
                    }
                
                Text("Settings")
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
