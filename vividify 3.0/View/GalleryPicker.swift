//
//  GalleryPicker.swift
//  vividify 3.0
//


import PhotosUI
import SwiftUI

struct GalleryPicker: UIViewControllerRepresentable {

    let onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {

        private let parent: GalleryPicker

        init(_ parent: GalleryPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { [parent] object, _ in
                guard let image = object as? UIImage else { return }
                Task { @MainActor in
                    parent.onImagePicked(image)
                }
            }
        }
    }
}
