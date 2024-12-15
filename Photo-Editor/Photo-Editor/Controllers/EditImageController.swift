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
    private let ciContext = CIContext()

    func applyFilterAndRotation(to image: UIImage, filter: FilterType, rotationAngle: CGFloat) -> UIImage {
        let filteredImage = applyFilter(to: image, filter: filter)
        return applyRotation(to: filteredImage, rotationAngle: rotationAngle)
    }

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

    private func applyTemperatureFilter(to image: UIImage, temperature: CGFloat) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        let filter = CIFilter.temperatureAndTint()
        filter.inputImage = ciImage
        filter.neutral = CIVector(x: temperature, y: 0)

        if let outputImage = filter.outputImage,
           let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }

        return image
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
