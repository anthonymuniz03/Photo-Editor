//
//  HomeScreenView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var lastViewedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    MainButton(lastViewedImage: $lastViewedImage)
                    Spacer()
                    HomeLibrary(lastViewedImage: lastViewedImage)
                }
                .navigationTitle("Choose an image")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    HomeScreenView()
}
