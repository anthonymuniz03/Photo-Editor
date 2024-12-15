////
//  EditImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/3/24.
//

import SwiftUI
import Photos

struct EditImageView: View {
    @State var image: UIImage
    @State private var filterController = EditImageController()
    var onSave: (Any) -> Void
    @Binding var isLoading: Bool
    @State private var uploadStatusMessage: String?
    @State private var showSaveConfirmation = false
    @State private var showErrorAlert = false
    @State private var showFilterDrawer = false
    @State private var originalImage: UIImage
    @State private var selectedFilter: FilterType = .original
    @State private var rotationAngle: CGFloat = 0
    @State private var currentFilteredImage: UIImage
    @Environment(\.dismiss) var dismiss

    init(image: UIImage, onSave: @escaping (Any) -> Void, isLoading: Binding<Bool>) {
        _image = State(initialValue: image)
        _originalImage = State(initialValue: image)
        _currentFilteredImage = State(initialValue: image)
        _isLoading = isLoading
        self.onSave = onSave
    }

    var body: some View {
        VStack {
            HStack(spacing: 40) {
                Button(action: rotateImageLeft) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }

                Button(action: rotateImageRight) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
            }
            .padding()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

            HStack(spacing: 20) {
                Button("Select Filter") {
                    showFilterDrawer.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()

            HStack {
                Button(action: uploadImageToCloudinary) {
                    Text("Upload and Save")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .disabled(isLoading)

                Button(action: saveImageToDevice) {
                    Text("Save to Device")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .disabled(isLoading)
            }
            .padding()
        }
        .alert("Saved to library", isPresented: $showSaveConfirmation) {
            Button("OK") {
                dismiss()
            }
        }
        .sheet(isPresented: $showFilterDrawer) {
            FilterSelectionView(currentImage: originalImage, selectedFilter: $selectedFilter) { filter in
                applyFilterAndRotation(filter)
            }
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Rotation Actions

    func rotateImageLeft() {
        DispatchQueue.global(qos: .userInitiated).async {
            let rotatedImage = filterController.rotateImageLeft(currentImage: currentFilteredImage, currentAngle: &rotationAngle)
            DispatchQueue.main.async {
                image = rotatedImage
            }
        }
    }

    func rotateImageRight() {
        DispatchQueue.global(qos: .userInitiated).async {
            let rotatedImage = filterController.rotateImageRight(currentImage: currentFilteredImage, currentAngle: &rotationAngle)
            DispatchQueue.main.async {
                image = rotatedImage
            }
        }
    }

    // MARK: - Filter and Rotation

    func applyFilterAndRotation(_ filter: FilterType) {
        image = filterController.applyFilterAndRotation(to: originalImage, filter: filter, rotationAngle: rotationAngle)
        currentFilteredImage = image
    }
    
    private func uploadImageToCloudinary() {
        isLoading = true
        uploadStatusMessage = "Uploading to Cloudinary..."

        PhotoController().uploadImageToCloudinary(image: image) { urlString in
            DispatchQueue.main.async {
                isLoading = false
                if let uploadedUrl = urlString {
                    uploadStatusMessage = "Upload successful!"
                    onSave(uploadedUrl)
                    dismiss()
                } else {
                    uploadStatusMessage = "Upload failed"
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func saveImageToDevice() {
        let photoController = PhotoController()
        
        photoController.saveImageToDevice(image: image) { error in
            DispatchQueue.main.async {
                if let error = error {
                    uploadStatusMessage = "Failed to save image: \(error.localizedDescription)"
                    showErrorAlert = true
                } else {
                    uploadStatusMessage = "Image successfully saved to your Photo Library."
                    showSaveConfirmation = true
                }
            }
        }
    }

}

#Preview {
    EditImageView(
        image: UIImage(named: "logo") ?? UIImage(),
        onSave: { _ in },
        isLoading: .constant(false)
    )
}
