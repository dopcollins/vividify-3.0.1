//
//  CropView.swift
//  vividify 3.0
//


import SwiftUI
import TOCropViewController
import UIKit

struct CropView: UIViewControllerRepresentable {

    let image: UIImage
    let onCrop: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> TOCropViewController {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: TOCropViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, TOCropViewControllerDelegate {

        private let parent: CropView

        init(_ parent: CropView) {
            self.parent = parent
        }

        func cropViewController(
            _ cropViewController: TOCropViewController,
            didCropTo image: UIImage,
            with cropRect: CGRect,
            angle: Int
        ) {
            parent.onCrop(image)
            parent.dismiss()
        }

        func cropViewController(
            _ cropViewController: TOCropViewController,
            didFinishCancelled cancelled: Bool
        ) {
            parent.dismiss()
        }
    }
}
