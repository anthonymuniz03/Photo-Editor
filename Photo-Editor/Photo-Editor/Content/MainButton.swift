//
//  MainButton.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

struct MainButton: View {
    @Binding var recentImages: [UIImage]
    var onImageSelected: (UIImage) -> Void

    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?

    let photoController = PhotoController()

    var body: some View {
        Button(action: {
            isPickerPresented = true
            print("Picker presented")
        }) {
            Image(systemName: "plus.circle")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundStyle(Color.gray)
                .padding(120)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("selectLibraryImage")
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let newImage {
                print("New image selected")
                onImageSelected(newImage)
            } else {
                print("No image selected")
            }
        }
    }
}

// Preview for development purposes
#Preview {
    MainButton(recentImages: .constant([]), onImageSelected: { _ in })
}
