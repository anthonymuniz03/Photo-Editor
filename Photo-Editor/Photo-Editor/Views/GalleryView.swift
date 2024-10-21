//
//  GalleryView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct GalleryView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MemorabiliaView()) {
                    Text("Memorabilia")
                }
                
                Section {
                    Button(action: {
                        print("Add new gallery tapped")
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add New Gallery")
                        }
                    }
                }
            }
            .navigationTitle("Gallery")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

#Preview {
    GalleryView()
}

