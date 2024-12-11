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

    let photoController = PhotoController()

    var body: some View {
        NavigationStack {
            VStack {
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

                NavigationLink(
                    value: selectedImage,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
            }
            .onChange(of: selectedImage) {
                if selectedImage != nil {
                    print("New image selected")
                    isEditImageViewActive = true
                } else {
                    print("No image selected")
                }
            }
            .navigationDestination(isPresented: $isEditImageViewActive) {
                if let image = selectedImage {
                    EditImageView(
                        image: image,
                        onSave: { savedImageOrUrl in
                            print("onSave closure called in NavigationLink.")

                            Task {
                                if let savedImage = savedImageOrUrl as? UIImage {
                                    print("UIImage received, starting Task to save...")
                                    await saveImageAndAddToLibrary(image: savedImage)
                                    print("Finished Task to save image.")
                                } else if let imageUrlString = savedImageOrUrl as? String {
                                    print("Cloudinary URL received: \(imageUrlString)")
                                    if let downloadedImage = await photoController.downloadImage(from: imageUrlString) {
                                        await saveImageAndAddToLibrary(image: downloadedImage)
                                        print("Image downloaded and saved to photo library.")
                                    } else {
                                        print("Failed to download image from Cloudinary URL.")
                                    }
                                } else {
                                    print("Unknown type received from onSave closure.")
                                }
                            }
                        }
                    )
                }
            }
        }
    }

    func saveImageAndAddToLibrary(image: UIImage) async {
        print("saveImageAndAddToLibrary function called...")
        do {
            print("Starting to save image...")
            let savedPath = try await photoController.saveImageToDevice(image: image)
            print("Image saved at: \(savedPath)")
            await MainActor.run {
                recentImages.append(image)
                print("Image saved and added to recentImages.")
                print("Current recentImages count: \(recentImages.count)")
                photoController.saveImagePaths(images: recentImages, key: "recentImagePaths")
            }
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    }
}

#Preview {
    MainButton(recentImages: .constant([]))
}
