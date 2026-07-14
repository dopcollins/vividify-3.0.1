//
//  AddImageScreen.swift
//  vividify 3.0
//

import SwiftUI

struct AddImageScreen: View {

    @EnvironmentObject private var controller: ImageEditController
    @State private var isPickerOptionSheetPresented = false

    var body: some View {
        VStack(spacing: 60) {
            Spacer()

            VStack(spacing: 20) {
                Button {
                    isPickerOptionSheetPresented.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray.opacity(0.7))
                }

                Text("Select an Image to Start Editing")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .sheet(isPresented: $isPickerOptionSheetPresented) {
            VStack(spacing: 20) {
                Text("Select Image Source")
                    .font(.headline)

                Button {
                    controller.isGalleryPickerPresented.toggle()
                    isPickerOptionSheetPresented = false
                } label: {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Choose from Gallery")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(.primary)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 2)
                    )
                    .cornerRadius(15)
                }

                Button {
                    controller.isCameraPickerPresented.toggle()
                    isPickerOptionSheetPresented = false
                } label: {
                    HStack {
                        Image(systemName: "camera")
                        Text("Take Photo")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundColor(.primary)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primary.opacity(0.3), lineWidth: 2)
                    )
                    .cornerRadius(15)
                }
            }
            .padding()
        }
        .sheet(isPresented: $controller.isGalleryPickerPresented) {
            GalleryPicker { controller.setImage($0) }
        }
        .sheet(isPresented: $controller.isCameraPickerPresented) {
            CameraPicker { controller.setImage($0) }
        }
    }
}
