//
//  Photo_EditorApp.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

@main
struct Photo_EditorApp: App {
    // TabBar Appearance
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 61/255, green: 168/255, blue: 116/255, alpha: 0.5)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
