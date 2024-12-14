//
//  EditImageView.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 11/3/24.
//

import SwiftUI
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

struct EditImageView: View {
    @State var image: UIImage
    var onSave: (Any) -> Void
    @Binding var isLoading: Bool
    @State private var uploadStatusMessage: String?
    @State private var showSaveConfirmation = false
    @State private var showErrorAlert = false
    @State private var showTextInput = false
    @State private var showFilterDrawer = false
    @State private var inputText: String = ""
    @State private var originalImage: UIImage
    @State private var selectedFilter: FilterType = .original
    @Environment(\.dismiss) var dismiss

    init(image: UIImage, onSave: @escaping (Any) -> Void, isLoading: Binding<Bool>) {
        _image = State(initialValue: image)
        _originalImage = State(initialValue: image)
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
                Button("Add Text") {
                    showTextInput = true
                }
                .buttonStyle(.borderedProminent)

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
        .alert("Image Saved!", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        }
        .alert("Failed to Save Image", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        }
        .textFieldAlert(isPresented: $showTextInput, title: "Enter Text", text: $inputText, onConfirm: applyTextOverlay)
        .navigationTitle("Edit Image")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isLoading)
        .sheet(isPresented: $showFilterDrawer) {
            FilterSelectionView(originalImage: originalImage, selectedFilter: $selectedFilter) { selectedImage in
                image = selectedImage
            }
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Image Editing Functions

    func applyTextOverlay() {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let newImage = renderer.image { context in
            image.draw(at: .zero)

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 50),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            let textSize = inputText.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (image.size.width - textSize.width) / 2,
                y: (image.size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )

            inputText.draw(in: textRect, withAttributes: attributes)
        }

        image = newImage
    }

    func rotateImageLeft() {
        rotateImage(by: -90)
    }

    func rotateImageRight() {
        rotateImage(by: 90)
    }

    func rotateImage(by degrees: CGFloat) {
        isLoading = true
        let photoController = PhotoController()

        DispatchQueue.global(qos: .userInitiated).async {
            let radians = degrees * (.pi / 180)
            let newSize = CGSize(width: self.image.size.height, height: self.image.size.width)
            let renderer = UIGraphicsImageRenderer(size: newSize)

            let rotatedImage = renderer.image { context in
                context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
                context.cgContext.rotate(by: radians)
                context.cgContext.translateBy(x: -self.image.size.width / 2, y: -self.image.size.height / 2)
                self.image.draw(at: .zero)
            }

            if let standardImage = photoController.convertToStandardFormat(image: rotatedImage) {
                DispatchQueue.main.async {
                    self.image = standardImage
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    print("Failed to convert rotated image to standard format.")
                }
            }
        }
    }

    private func uploadImageToCloudinary() {
        isLoading = true
        uploadStatusMessage = "Uploading to Cloudinary..."

        Task {
            do {
                if let uploadedUrl = try await PhotoController().uploadImageToCloudinary(image: image) {
                    await MainActor.run {
                        uploadStatusMessage = "Upload successful!"
                        isLoading = false
                        onSave(uploadedUrl)
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    uploadStatusMessage = "Upload failed: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }

    private func saveImageToDevice() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                DispatchQueue.main.async {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    showSaveConfirmation = true
                }
            } else {
                showErrorAlert = true
            }
        }
    }
}

enum FilterType {
    case original, cold, warm
}

// MARK: - Filter Selection View

struct FilterSelectionView: View {
    let originalImage: UIImage
    @Binding var selectedFilter: FilterType
    var onSelect: (UIImage) -> Void

    var body: some View {
        VStack {
            Text("Select a Filter")
                .font(.headline)
                .padding()

            HStack(spacing: 20) {
                filterButton(for: .original, label: "Original", image: originalImage)
                filterButton(for: .cold, label: "Cold", image: applyFilter(to: originalImage, temperature: 4500))
                filterButton(for: .warm, label: "Warm", image: applyFilter(to: originalImage, temperature: 8500))
            }
            .padding()
        }
    }

    func filterButton(for filter: FilterType, label: String, image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: selectedFilter == filter ? 100 : 80, height: selectedFilter == filter ? 100 : 80)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedFilter == filter ? Color.white : Color.clear, lineWidth: 3)
            )
            .onTapGesture {
                selectedFilter = filter
                onSelect(image)
            }
            .padding(.horizontal, 5)
    }

    func applyFilter(to image: UIImage, temperature: CGFloat) -> UIImage {
        let context = CIContext()
        let ciImage = CIImage(image: image)!
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = ciImage
        filter.neutral = CIVector(x: temperature, y: 0)
        let outputImage = filter.outputImage!
        let cgImage = context.createCGImage(outputImage, from: outputImage.extent)!
        return UIImage(cgImage: cgImage)
    }
}


struct FilterPreview: View {
    let image: UIImage
    let label: String
    let applyFilter: (UIImage) -> UIImage

    var body: some View {
        VStack {
            Image(uiImage: applyFilter(image))
                .resizable()
                .frame(width: 80, height: 80)
                .cornerRadius(8)
            Text(label)
        }
    }
}

// MARK: - Text Field Alert Modifier

extension View {
    func textFieldAlert(isPresented: Binding<Bool>, title: String, text: Binding<String>, onConfirm: @escaping () -> Void) -> some View {
        TextFieldAlertWrapper(isPresented: isPresented, title: title, text: text, onConfirm: onConfirm, content: self)
    }
}

struct TextFieldAlertWrapper<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    @Binding var text: String
    let onConfirm: () -> Void
    let content: Content

    var body: some View {
        content.alert(title, isPresented: $isPresented) {
            TextField("Enter text", text: $text)
            Button("OK", action: onConfirm)
            Button("Cancel", role: .cancel) {}
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
