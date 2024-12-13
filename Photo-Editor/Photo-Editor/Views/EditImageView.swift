//
//  EditImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/3/24.
//

import SwiftUI
import Photos

struct EditImageView: View {
    var image: UIImage
    var onSave: (Any) -> Void
    @Binding var isLoading: Bool
    @State private var uploadStatusMessage: String?
    @State private var showSaveConfirmation = false
    @State private var showErrorAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()

                if let uploadStatusMessage = uploadStatusMessage {
                    Text(uploadStatusMessage)
                        .foregroundColor(.gray)
                        .padding()
                }

                HStack {
                    Button(action: {
                        uploadImageToCloudinary()
                    }) {
                        Text("Upload and Save Image")
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
            .blur(radius: isLoading ? 3 : 0)
        }
        .alert("Image Saved!", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
        .alert("Failed to Save Image", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        }
        .navigationTitle("Edit Image")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isLoading)
    }

    private func uploadImageToCloudinary() {
        isLoading = true
        uploadStatusMessage = "Uploading to Cloudinary..."

        Task {
            do {
                if let uploadedUrl = try await PhotoController().uploadImageToCloudinary(image: image) {
                    DispatchQueue.main.async {
                        uploadStatusMessage = "Upload successful!"
                    }
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    DispatchQueue.main.async {
                        isLoading = false
                        onSave(uploadedUrl)
                        dismiss()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    isLoading = false
                    uploadStatusMessage = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func saveImageToDevice() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                DispatchQueue.main.async {
                    let imageSaver = ImageSaver {
                        showSaveConfirmation = true
                    } onFailure: {
                        showErrorAlert = true
                    }
                    imageSaver.saveImage(image)
                }
            } else {
                showErrorAlert = true
            }
        }
    }
}

class ImageSaver: NSObject {
    private let onSuccess: () -> Void
    private let onFailure: () -> Void

    init(onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }

    func saveImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let _ = error {
            onFailure()
        } else {
            onSuccess()
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
