//
//  DrawOnImageView.swift
//  vividify 3.0
//

import PencilKit
import SwiftUI

struct DrawOnImageView: View {

    let image: UIImage
    let onCommit: (UIImage) -> Void

    @StateObject private var controller = DrawingController()

    @State private var canvasView = PKCanvasView()
    @State private var isToolPickerVisible = true
    @State private var imageFrame: CGRect = .zero
    @State private var hapticEngine = UIImpactFeedbackGenerator(style: .medium)
    @State private var showSaveSuccess = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Image and Canvas Area
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(.ultraThinMaterial, lineWidth: 1)
                                    .opacity(0.3)
                            )
                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                            .background {
                                GeometryReader { imageGeo in
                                    Color.clear.onAppear {
                                        updateCanvasSize(imageSize: image.size, displaySize: imageGeo.size)
                                    }
                                }
                            }

                        CanvasView(canvas: $canvasView, isToolPickerVisible: $isToolPickerVisible)
                            .frame(width: imageFrame.width, height: imageFrame.height)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer(minLength: 20)

            // Single line button layout
            HStack(spacing: 8) {
                Button {
                    performAction {
                        canvasView.drawing = PKDrawing()
                    }
                } label: {
                    liquidGlassButton(
                        title: "Clear",
                        systemImage: "trash.fill",
                        color: .red,
                        style: .destructive
                    )
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: canvasView.drawing.bounds.isEmpty)

                Button {
                    performAction {
                        isToolPickerVisible.toggle()
                    }
                } label: {
                    liquidGlassButton(
                        title: isToolPickerVisible ? "Hide" : "Tools",
                        systemImage: isToolPickerVisible ? "pencil.slash" : "pencil.tip.crop.circle.badge.plus",
                        color: .blue,
                        style: .standard
                    )
                }
                .sensoryFeedback(.selection, trigger: isToolPickerVisible)

                Button {
                    performAction {
                        dismiss()
                    }
                } label: {
                    liquidGlassButton(
                        title: "Cancel",
                        systemImage: "xmark.circle.fill",
                        color: .secondary,
                        style: .standard
                    )
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: false)

                Button {
                    saveDrawing()
                } label: {
                    liquidGlassButton(
                        title: controller.isProcessing ? "Saving" : "Save",
                        systemImage: "checkmark.circle.fill",
                        color: .green,
                        style: .standard,
                        isLoading: controller.isProcessing
                    )
                }
                .disabled(controller.isProcessing)
                .sensoryFeedback(.success, trigger: showSaveSuccess)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                MeshGradient(
                                    width: 3,
                                    height: 3,
                                    points: [
                                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                                        [0.0, 0.5], [0.3, 0.3], [1.0, 0.5],
                                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                                    ],
                                    colors: [
                                        .white.opacity(0.4), .white.opacity(0.2), .white.opacity(0.4),
                                        .white.opacity(0.1), .clear, .white.opacity(0.1),
                                        .white.opacity(0.2), .white.opacity(0.05), .white.opacity(0.2)
                                    ]
                                )
                            )
                            .blendMode(.plusLighter)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                            .blur(radius: 0.5)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 12)
                    .shadow(color: .black.opacity(0.05), radius: 40, x: 0, y: 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 60)
        }
        .background {
            MeshGradient(
                width: 2,
                height: 2,
                points: [
                    [0.0, 0.0], [1.0, 0.0],
                    [0.0, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3),
                    Color(.systemGray5).opacity(0.2),
                    Color(.systemBackground)
                ]
            )
            .ignoresSafeArea()
        }
        .navigationTitle("Draw on Image")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.regularMaterial, for: .navigationBar)
        .onAppear {
            hapticEngine.prepare()
        }
    }

    // MARK: - Actions

    private func performAction(_ action: @escaping () -> Void) {
        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.1)) {
            action()
        }
        hapticEngine.impactOccurred(intensity: 0.7)
    }

    private func saveDrawing() {
        let drawing = canvasView.drawing
        let bounds = canvasView.bounds

        Task {
            let flattened = await controller.flatten(drawing, canvasBounds: bounds, onto: image)

            onCommit(flattened)
            canvasView.drawing = PKDrawing()

            showSaveSuccess = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            try? await Task.sleep(for: .milliseconds(500))
            dismiss()
        }
    }

    private func updateCanvasSize(imageSize: CGSize, displaySize: CGSize) {
        guard imageSize.height > 0 else { return }

        let aspectRatio = imageSize.width / imageSize.height
        let newWidth = min(displaySize.width, displaySize.height * aspectRatio)
        let newHeight = newWidth / aspectRatio

        imageFrame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        canvasView.frame = imageFrame
        canvasView.bounds = imageFrame
    }

    // MARK: - Components

    enum ButtonStyle {
        case standard, primary, destructive
    }

    private func liquidGlassButton(
        title: String,
        systemImage: String,
        color: Color,
        style: ButtonStyle,
        isLoading: Bool = false
    ) -> some View {
        VStack(spacing: 6) {
            ZStack {
                if isLoading {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20, weight: .medium))
                        .symbolEffect(.rotate.byLayer, isActive: isLoading)
                        .foregroundStyle(style == .primary ? .white : color)
                } else {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(style == .primary ? .white : color)
                        .symbolEffect(.bounce, value: isLoading)
                }
            }
            .frame(width: 40, height: 40)
            .background {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
            }

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(style == .primary ? .white : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.3),
                                    .white.opacity(0.1),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.plusLighter)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                }
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .overlay {
            if style == .primary {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        MeshGradient(
                            width: 2,
                            height: 2,
                            points: [
                                [0.0, 0.0], [1.0, 0.0],
                                [0.0, 1.0], [1.0, 1.0]
                            ],
                            colors: [
                                color.opacity(0.95),
                                color.opacity(0.8),
                                color.opacity(0.75),
                                color.opacity(0.9)
                            ]
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
            }
        }
        .scaleEffect(isLoading ? 0.98 : 1.0)
        .animation(.bouncy(duration: 0.3, extraBounce: 0.1), value: isLoading)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

// MARK: - Canvas

struct CanvasView: UIViewRepresentable {

    @Binding var canvas: PKCanvasView
    @Binding var isToolPickerVisible: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.tool = PKInkingTool(.pen, color: .label, width: 3)
        canvas.maximumSupportedContentVersion = .version2

        context.coordinator.setupToolPicker(for: canvas)
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        context.coordinator.updateToolPickerVisibility(isVisible: isToolPickerVisible, for: uiView)
    }

    @MainActor
    final class Coordinator {

        private let parent: CanvasView
        private let toolPicker = PKToolPicker()

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        func setupToolPicker(for canvas: PKCanvasView) {
            toolPicker.addObserver(canvas)
            toolPicker.overrideUserInterfaceStyle = .unspecified
            toolPicker.setVisible(parent.isToolPickerVisible, forFirstResponder: canvas)

            if parent.isToolPickerVisible {
                canvas.becomeFirstResponder()
            }
        }

        func updateToolPickerVisibility(isVisible: Bool, for canvas: PKCanvasView) {
            toolPicker.setVisible(isVisible, forFirstResponder: canvas)
            if isVisible {
                canvas.becomeFirstResponder()
            }
        }
    }
}
