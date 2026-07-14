//
//  DrawingController.swift
//  vividify 3.0
//
//  Controller for the Draw tool. Flattens a PencilKit drawing onto the image.


import PencilKit
import SwiftUI
import UIKit

@MainActor
final class DrawingController: ObservableObject {

    @Published private(set) var isProcessing = false

    func flatten(
        _ drawing: PKDrawing,
        canvasBounds: CGRect,
        onto image: UIImage
    ) async -> UIImage {
        guard canvasBounds.width > 0, !drawing.bounds.isEmpty else { return image }

        isProcessing = true
        defer { isProcessing = false }

        let scale = image.size.width / canvasBounds.width
        let overlay = drawing.image(from: canvasBounds, scale: scale)

        return await ImageProcessor.shared.composite(overlay, onto: image)
    }
}
