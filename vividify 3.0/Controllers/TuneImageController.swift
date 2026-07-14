//
//  TuneImageController.swift
//  vividify 3.0
//

import SwiftUI
import UIKit

@MainActor
final class TuneImageController: ObservableObject {

    @Published var adjustments = TuneAdjustments() {
        didSet { schedulePreview() }
    }

    @Published private(set) var previewImage: UIImage?
    @Published private(set) var isProcessing = false

    private var sourceImage: UIImage?
    private var previewTask: Task<Void, Never>?

    private static let debounce = Duration.milliseconds(80)

    // MARK: - Lifecycle

    func start(with image: UIImage) {
        guard sourceImage == nil else { return }
        sourceImage = image
        previewImage = image
    }

    // MARK: - Preview

    private func schedulePreview() {
        guard let sourceImage else { return }

        previewTask?.cancel()
        isProcessing = true

        let adjustments = adjustments
        previewTask = Task { [weak self] in
            try? await Task.sleep(for: Self.debounce)
            guard !Task.isCancelled else { return }

            let result = await ImageProcessor.shared.apply(adjustments, to: sourceImage)
            guard !Task.isCancelled else { return }

            self?.previewImage = result
            self?.isProcessing = false
        }
    }

    // MARK: - Commit

    func renderFinalImage() async -> UIImage? {
        guard let sourceImage else { return nil }
        return await ImageProcessor.shared.apply(adjustments, to: sourceImage)
    }

    func reset() {
        adjustments = .identity
    }
}
