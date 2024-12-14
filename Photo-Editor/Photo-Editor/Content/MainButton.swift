//
//  MainButton.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

struct MainButton: View {
    @Binding var recentImages: [UIImage]
    @Binding var selectedImage: UIImage?
    @Binding var isEditImageViewActive: Bool
    var onImageSelected: (UIImage) -> Void

    @State private var isPickerPresented = false

    let photoController = PhotoController()

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.3))
                .frame(width: 350, height: 350)

            Image(systemName: "plus.circle")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundColor(.white.opacity(0.6))
        }
        .onTapGesture {
            isPickerPresented = true
            print("Picker presented")
        }
        .accessibilityLabel("selectLibraryImage")
        .sheet(isPresented: $isPickerPresented) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            if let newImage {
                print("New image selected")
                onImageSelected(newImage)
                isEditImageViewActive = true
            } else {
                print("No image selected")
            }
        }
    }
}

#Preview {
    MainButton(
        recentImages: .constant([]),
        selectedImage: .constant(nil),
        isEditImageViewActive: .constant(false),
        onImageSelected: { _ in }
    )
}
