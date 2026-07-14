//
//  DetailsView.swift
//  vividify 3.0
//

import SwiftUI

struct DetailsView: View {

    let image: UIImage
    let onCommit: (UIImage) -> Void

    @StateObject private var controller = DetailsController()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image(uiImage: controller.previewImage ?? image)
                .resizable()
                .scaledToFit()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Brightness")
                        Slider(value: $controller.adjustments.brightness, in: -1...1)

                        Text("Contrast")
                        Slider(value: $controller.adjustments.contrast, in: 0...2)

                        Text("Saturation")
                        Slider(value: $controller.adjustments.saturation, in: 0...2)

                        Text("Warmth")
                        Slider(value: $controller.adjustments.warmth, in: -1...1)

                        Text("Shadows")
                        Slider(value: $controller.adjustments.shadows, in: -1...1)
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
