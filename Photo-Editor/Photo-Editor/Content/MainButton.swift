//
//  MainButton.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 10/10/24.
//

import SwiftUI

struct MainButton: View {
    @Binding var recentImages: [UIImage]
    @State private var isPickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var isEditImageViewActive = false

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    isPickerPresented = true
                    print("Picker presented")
                }, label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundStyle(Color.gray)
                        .padding(120)
                })
                .buttonStyle(.bordered)
                .accessibilityLabel("selectLibraryImage")
                .sheet(isPresented: $isPickerPresented) {
                    PhotoPicker(selectedImage: $selectedImage)
                }

                NavigationLink(
                    destination: EditImageView(image: selectedImage ?? UIImage()),
                    isActive: $isEditImageViewActive
                ) {
                    EmptyView()
                }
                .hidden()

                .onChange(of: selectedImage) { newImage in
                    if let newImage = newImage {
                        print("New image selected")
                        
                        if recentImages.count < 15 {
                            recentImages.append(newImage)
                        } else {
                            recentImages.removeFirst()
                            recentImages.append(newImage)
                        }
                        isEditImageViewActive = true
                        print("Image added to recentImages, total count: \(recentImages.count)")
                    } else {
                        print("No image selected")
                    }
                }
            }
        }
    }
}

#Preview {
    MainButton(recentImages: .constant([]))
}
