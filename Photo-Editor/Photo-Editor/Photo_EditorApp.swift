//
//  Photo_EditorApp.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

@main
struct Photo_EditorApp: App {
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
            ContentView()
        }
    }
}
