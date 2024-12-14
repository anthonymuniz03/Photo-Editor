//
//  SettingsView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("General")) {
                    NavigationLink(destination: Text("Profile Settings")) {
                        Text("Profile")
                    }
                    
                    NavigationLink(destination: Text("Notifications Settings")) {
                        Text("Notifications")
                    }
                    
                    NavigationLink(destination: Text("Appearance Settings")) {
                        Text("Appearance")
                    }
                    
                    NavigationLink(destination: Text("Version Number: 0.0.0")) {
                        Text("Version")
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    SettingsView()
}
