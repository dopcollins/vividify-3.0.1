//
//  ImageProcessor.swift
//  vividify 3.0
//

import CoreImage
import CoreImage.CIFilterBuiltins
import Metal
import UIKit

actor ImageProcessor {

    static let shared = ImageProcessor()

    private let context: CIContext

    private init() {
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            context = CIContext(mtlDevice: metalDevice)
        } else {
            context = CIContext()
        }
    }

    // MARK: - Detail adjustments

    func apply(_ adjustments: DetailAdjustments, to image: UIImage) -> UIImage {
        guard !adjustments.isIdentity, let input = CIImage(image: image) else { return image }

        let sourceExtent = input.extent
        var output = input

        if adjustments.brightness != 0 || adjustments.contrast != 1 || adjustments.saturation != 1 {
            let filter = CIFilter.colorControls()
            filter.inputImage = output
            filter.brightness = Float(adjustments.brightness)
            filter.contrast = Float(adjustments.contrast)
            filter.saturation = Float(adjustments.saturation)
            output = filter.outputImage ?? output
        }

        if adjustments.warmth != 0 {
            let filter = CIFilter.temperatureAndTint()
            filter.inputImage = output
            filter.neutral = CIVector(x: 6500 + CGFloat(adjustments.warmth * 1000), y: 0)
            output = filter.outputImage ?? output
        }

        if adjustments.shadows != 0 {
            let filter = CIFilter.highlightShadowAdjust()
            filter.inputImage = output
            filter.shadowAmount = Float(adjustments.shadows)
            output = filter.outputImage ?? output
        }

        return render(output, croppedTo: sourceExtent, matching: image)
    }

    // MARK: - Tune adjustments

    func apply(_ adjustments: TuneAdjustments, to image: UIImage) -> UIImage {
        guard !adjustments.isIdentity, let input = CIImage(image: image) else { return image }

        let sourceExtent = input.extent
        var output = input

        if adjustments.smoothness > 0 {
            let filter = CIFilter.gaussianBlur()
            // Clamping first stops the blur from sampling transparent pixels
            // beyond the edge, which is what produced the dark border.
            filter.inputImage = output.clampedToExtent()
            filter.radius = Float(adjustments.smoothness * 8)
            output = filter.outputImage ?? output
        }

        if adjustments.sharpness > 0 {
            let filter = CIFilter.unsharpMask()
            filter.inputImage = output
            filter.radius = Float(adjustments.sharpness * 2.5)
            filter.intensity = Float(adjustments.sharpness * 0.8)
            output = filter.outputImage ?? output
        }

        return render(output, croppedTo: sourceExtent, matching: image)
    }

    // MARK: - Compositing

    /// Draws `overlay` on top of `base` at the base image's native size.
    func composite(_ overlay: UIImage, onto base: UIImage) -> UIImage {
        let size = base.size
        guard size.width > 0, size.height > 0 else { return base }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = base.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            let bounds = CGRect(origin: .zero, size: size)
            base.draw(in: bounds)
            overlay.draw(in: bounds)
        }
    }

    // MARK: - Rendering

    /// Renders to a UIImage, cropping back to the source extent.
    ///
    /// Blur filters grow the output extent. Rendering from `output.extent`
    /// therefore produced an image slightly larger than the original on every
    /// pass, so repeated edits drifted in size. Cropping to the extent we
    /// captured before filtering keeps the dimensions stable.
    private func render(_ ciImage: CIImage, croppedTo extent: CGRect, matching source: UIImage) -> UIImage {
        guard let cgImage = context.createCGImage(ciImage, from: extent) else { return source }
        return UIImage(cgImage: cgImage, scale: source.scale, orientation: source.imageOrientation)
    }
}
