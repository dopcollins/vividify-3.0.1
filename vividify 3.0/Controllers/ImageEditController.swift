//
//  ImageEditController.swift
//  vividify 3.0
//


import SwiftUI
import UIKit

@MainActor
final class ImageEditController: ObservableObject {

    /// The image currently being edited. Only this controller may write to it.
    @Published private(set) var currentImage: UIImage?

    @Published var isGalleryPickerPresented = false
    @Published var isCameraPickerPresented = false
    @Published var isSaveAlertPresented = false

    @Published private(set) var isSaving = false
    @Published private(set) var didSaveSuccessfully = false
    @Published private(set) var saveErrorMessage: String?

    var hasImage: Bool { currentImage != nil }

    // MARK: - Editing

    func setImage(_ image: UIImage) {
        currentImage = image
    }

    /// Commits the result of a tool. All tools funnel through here, which is what
    /// makes this controller the source of truth rather than an ornament.
    func commit(_ image: UIImage) {
        currentImage = image
    }

    func clearImage() {
        currentImage = nil
    }

    // MARK: - Saving

    func saveCurrentImageToPhotos() async {
        guard let image = currentImage, !isSaving else { return }

        isSaving = true
        defer { isSaving = false }

        do {
            try await PhotoLibraryService.save(image)
            didSaveSuccessfully = true
            saveErrorMessage = nil
        } catch {
            didSaveSuccessfully = false
            saveErrorMessage = error.localizedDescription
        }

        isSaveAlertPresented = true
    }
}
