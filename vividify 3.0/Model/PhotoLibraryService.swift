//
//  PhotoLibraryService.swift
//  vividify 3.0
//


import Photos
import UIKit

enum PhotoLibraryError: LocalizedError {

    case permissionDenied
    case saveFailed(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Vividify needs permission to add photos to your library."
        case .saveFailed(let error):
            return error.localizedDescription
        }
    }
}

struct PhotoLibraryService {

    static func save(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.permissionDenied
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            throw PhotoLibraryError.saveFailed(error)
        }
    }
}
