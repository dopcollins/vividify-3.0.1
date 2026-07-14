//
//  ContentView.swift
//  vividify 3.0
//

import SwiftUI

struct ContentView: View {

    @StateObject private var controller = ImageEditController()
    @State private var isAddScreen = true

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if controller.hasImage {
                    ImageEditorScreen()
                        .environmentObject(controller)
                } else if isAddScreen {
                    AddImageScreen()
                        .environmentObject(controller)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("VIVIDIFY")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    if !isAddScreen && controller.hasImage {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isAddScreen = true
                                controller.clearImage()
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .onChange(of: controller.currentImage) { _, newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isAddScreen = (newValue == nil)
                }
            }
            .alert("Save Result", isPresented: $controller.isSaveAlertPresented) {
                Button("OK") { }
            } message: {
                Text(controller.didSaveSuccessfully
                     ? "Image saved successfully!"
                     : controller.saveErrorMessage ?? "Failed to save image")
            }
        }
    }
}

#Preview {
    ContentView()
}
