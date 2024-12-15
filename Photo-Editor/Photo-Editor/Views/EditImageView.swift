////
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

    func rotateImageLeft() {
        rotationAngle -= 90
        rotationAngle = rotationAngle.truncatingRemainder(dividingBy: 360)
        applyRotation()
    }

    func rotateImageRight() {
        rotationAngle += 90
        rotationAngle = rotationAngle.truncatingRemainder(dividingBy: 360)
        applyRotation()
    }






    func rotateImage(by degrees: CGFloat) {
        let radians = degrees * (.pi / 180)
        let newSize = CGSize(width: image.size.height, height: image.size.width)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        let rotatedImage = renderer.image { context in
            context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            context.cgContext.rotate(by: radians)
            context.cgContext.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
            image.draw(at: .zero)
        }

        image = rotatedImage
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

    func applyFilterAndRotation(_ filter: FilterType) {
        switch filter {
        case .original:
            currentFilteredImage = originalImage
        case .cold:
            currentFilteredImage = applyTemperatureFilter(to: originalImage, temperature: 4500)
        case .warm:
            currentFilteredImage = applyTemperatureFilter(to: originalImage, temperature: 8500)
        }
        applyRotation()
    }



    
    func applyTemperatureFilter(to inputImage: UIImage, temperature: CGFloat) -> UIImage {
        let ciContext = CIContext()
        let ciImage = CIImage(image: inputImage)!
        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = ciImage
        filter.neutral = CIVector(x: temperature, y: 0)

        if let outputImage = filter.outputImage,
           let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }

        return inputImage
    }
    
    func applyRotation() {
        let radians = rotationAngle * (.pi / 180)
        let newSize = CGSize(
            width: abs(cos(radians)) * currentFilteredImage.size.width + abs(sin(radians)) * currentFilteredImage.size.height,
            height: abs(sin(radians)) * currentFilteredImage.size.width + abs(cos(radians)) * currentFilteredImage.size.height
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)

        let rotatedImage = renderer.image { context in
            context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            context.cgContext.rotate(by: radians)
            context.cgContext.translateBy(x: -currentFilteredImage.size.width / 2, y: -currentFilteredImage.size.height / 2)
            currentFilteredImage.draw(at: .zero)
        }

        image = rotatedImage
    }




}

// MARK: - FilterType Enum

enum FilterType {
    case original, cold, warm
}


struct FilterSelectionView: View {
    let currentImage: UIImage
    @Binding var selectedFilter: FilterType
    var onSelect: (FilterType) -> Void

    var body: some View {
        VStack {
            Text("Select a Filter")
                .font(.headline)
                .padding()

            HStack(spacing: 20) {
                filterButton(for: .original, label: "Original", color: Color.gray)
                filterButton(for: .cold, label: "Cold", color: Color.blue)
                filterButton(for: .warm, label: "Warm", color: Color.orange)
            }
            .padding()
        }
    }

    func filterButton(for filter: FilterType, label: String, color: Color) -> some View {
        VStack {
            color
                .frame(width: selectedFilter == filter ? 100 : 80, height: selectedFilter == filter ? 100 : 80)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedFilter == filter ? Color.white : Color.clear, lineWidth: 3)
                )
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
        .onTapGesture {
            selectedFilter = filter
            onSelect(filter)
        }
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
