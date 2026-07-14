//
//  ToolsView.swift
//  vividify 3.0
//
//  The tool row is built from EditingTool.allCases, so the titles and symbols
//  are no longer duplicated between the model and the view.
//

import SwiftUI
import UIKit

struct ToolsView: View {

    @EnvironmentObject private var controller: ImageEditController
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            // image
            if let image = controller.currentImage {
                GeometryReader { geometry in
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: geometry.size.height * 0.7)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }

            Spacer(minLength: 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 25) {
                    ForEach(EditingTool.allCases) { tool in
                        NavigationLink {
                            destination(for: tool)
                        } label: {
                            toolButton(title: tool.title, systemImage: tool.systemImage)
                        }
                    }
                }
                .padding(.horizontal, 25)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                )
                .padding(.horizontal, 15)
            }

            Button {
                dismiss()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))

                    Text("Apply Changes")
                        .font(.system(size: 17, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundColor(.white)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.9),
                                    Color.blue.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                }
            }
        }
    }

    // MARK: - Destinations

    @ViewBuilder
    private func destination(for tool: EditingTool) -> some View {
        if let image = controller.currentImage {
            switch tool {
            case .crop:
                CropView(image: image) { controller.commit($0) }
            case .details:
                DetailsView(image: image) { controller.commit($0) }
            case .tune:
                TuneImageView(image: image) { controller.commit($0) }
            case .draw:
                DrawOnImageView(image: image) { controller.commit($0) }
            }
        }
    }

    // MARK: - Components

    private func toolButton(title: String, systemImage: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption.bold())
                .foregroundColor(.primary)
        }
        .frame(width: 70, height: 70)
        .background(
            Circle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        )
        .contentShape(Circle())
        .accessibilityLabel(title)
    }
}
