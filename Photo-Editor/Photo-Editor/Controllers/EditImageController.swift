//
//  EditImageController.swift
//  Photo-Editor
//
//  Created by Anthony Muñiz on 12/14/24.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

class EditImageController {
    private static let sharedCIContext = CIContext(options: nil)
    private let ciContext = EditImageController.sharedCIContext

    func applyFilter(to image: UIImage, filter: FilterType) -> UIImage {
        switch filter {
        case .original:
            return image
        case .cold:
            return applyTemperatureFilter(to: image, temperature: 4500)
        case .warm:
            return applyTemperatureFilter(to: image, temperature: 8500)
        }
    }

    func applyLowQualityFilter(to image: UIImage, filter: FilterType) -> UIImage {
        return applyTemperatureFilter(to: image, temperature: filter == .cold ? 4500 : 8500, targetSize: CGSize(width: 400, height: 400))
    }

    func applyFilterAndRotation(to image: UIImage, filter: FilterType, rotationAngle: CGFloat) -> UIImage {
        let filteredImage = applyFilter(to: image, filter: filter)
        return applyRotation(to: filteredImage, rotationAngle: rotationAngle)
    }

    private func applyTemperatureFilter(to image: UIImage, temperature: CGFloat, targetSize: CGSize = CGSize(width: 800, height: 800)) -> UIImage {
        guard let downsampledImage = downsample(image: image, to: targetSize),
              let ciImage = CIImage(image: downsampledImage)?.oriented(forExifOrientation: Int32(image.imageOrientation.rawValue)) else {
            return image
        }

        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = ciImage
        filter.neutral = CIVector(x: temperature, y: 0)

        guard let outputImage = filter.outputImage,
              let cgImage = ciContext.createCGImage(outputImage, from: ciImage.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private func downsample(image: UIImage, to targetSize: CGSize) -> UIImage? {
        let imageData = image.jpegData(compressionQuality: 0.7)
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: max(targetSize.width, targetSize.height)
        ]

        guard let data = imageData,
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let downsampledCGImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return nil
        }

        return UIImage(cgImage: downsampledCGImage)
    }

    func applyRotation(to image: UIImage, rotationAngle: CGFloat) -> UIImage {
        let radians = rotationAngle * (.pi / 180)
        let newSize = CGSize(
            width: abs(cos(radians)) * image.size.width + abs(sin(radians)) * image.size.height,
            height: abs(sin(radians)) * image.size.width + abs(cos(radians)) * image.size.height
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { context in
            context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
            context.cgContext.rotate(by: radians)
            context.cgContext.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
            image.draw(at: .zero)
        }
    }

    private func downscaleImage(_ image: UIImage, to targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func rotateImageLeft(currentImage: UIImage, currentAngle: inout CGFloat) -> UIImage {
        currentAngle -= 90
        currentAngle = currentAngle.truncatingRemainder(dividingBy: 360)
        return applyRotation(to: currentImage, rotationAngle: currentAngle)
    }

    func rotateImageRight(currentImage: UIImage, currentAngle: inout CGFloat) -> UIImage {
        currentAngle += 90
        currentAngle = currentAngle.truncatingRemainder(dividingBy: 360)
        return applyRotation(to: currentImage, rotationAngle: currentAngle)
    }
}
