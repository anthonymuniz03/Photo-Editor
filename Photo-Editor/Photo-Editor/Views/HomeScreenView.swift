//
//  HomeScreenView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct HomeScreenView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    
                    MainButton()
                    Spacer()
                    HomeLibrary()
                }
                .navigationTitle("Bwomp")

            }
        }

        }
    }

#Preview {
    HomeScreenView()
}
