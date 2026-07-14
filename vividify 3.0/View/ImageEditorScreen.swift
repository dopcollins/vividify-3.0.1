//
//  ImageEditorScreen.swift
//  vividify 3.0
//

import SwiftUI

struct ImageEditorScreen: View {

    @EnvironmentObject private var controller: ImageEditController

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ZStack {
                    if let image = controller.currentImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: geometry.size.height * 0.85)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(maxHeight: geometry.size.height * 0.85)
                            .overlay(ProgressView("Loading..."))
                    }

                    if controller.isSaving {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Processing...")
                                .font(.headline)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            VStack(spacing: 20) {
                NavigationLink {
                    ToolsView()
                        .environmentObject(controller)
                } label: {
                    glassButton(title: "Edit Tools", systemImage: "wrench.and.screwdriver", showChevron: true)
                }

                Button {
                    Task { await controller.saveCurrentImageToPhotos() }
                } label: {
                    glassButton(title: "Save to Photos", systemImage: "square.and.arrow.up", showChevron: false)
                }
                .disabled(controller.isSaving)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 25)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 0.8)
                    )
                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            )
            .padding(.horizontal, 15)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private func glassButton(title: String, systemImage: String, showChevron: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .medium))
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}
