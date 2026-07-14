//
//  TuneImageView.swift
//  vividify 3.0
//

import SwiftUI

struct TuneImageView: View {

    let image: UIImage
    let onCommit: (UIImage) -> Void

    @StateObject private var controller = TuneImageController()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            if let previewImage = controller.previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()
                    .edgesIgnoringSafeArea(.all)
                    .padding(8)
            } else {
                Text("Loading image...")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }

            VStack {
                Spacer()

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gaussian Blur")
                        Slider(value: $controller.adjustments.smoothness, in: 0...2)

                        Text("Sharpness")
                        Slider(value: $controller.adjustments.sharpness, in: 0...2)
                    }
                    .padding()
                }
                .frame(height: UIScreen.main.bounds.height / 4)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding()
            }
        }
        .onAppear { controller.start(with: image) }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Apply") {
                    Task {
                        if let final = await controller.renderFinalImage() {
                            onCommit(final)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
