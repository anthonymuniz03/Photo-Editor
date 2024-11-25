//
//  GalleryView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/20/24.
//

import SwiftUI

struct GalleryView: View {
    @State private var albums: [AlbumID] = [AlbumID(name: "Memorabilia", images: [])]
    @State private var showPhotoPicker = false
    @State private var newAlbumName = ""
    @State private var showAlbumNameAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(albums) { album in
                    NavigationLink(destination: AlbumView(album: album)) {
                        Text(album.name)
                    }
                }
                
                Section {
                    Button(action: {
                        showAlbumNameAlert = true
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
            .alert("Enter Album Name", isPresented: $showAlbumNameAlert) {
                TextField("Album Name", text: $newAlbumName)
                Button("Create") {
                    showPhotoPicker = true
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerView(onImagesSelected: { selectedImages in
                    let newAlbum = AlbumID(name: newAlbumName, images: selectedImages)
                    albums.append(newAlbum)
                    newAlbumName = ""
                })
            }
        }
    }
}

#Preview {
    GalleryView()
}
