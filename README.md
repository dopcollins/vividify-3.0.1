# Vividify 3.0

A SwiftUI photo editor for iOS with live-preview adjustments, cropping, and freehand annotation.

## Features

**Core editing**
- **Details** — brightness, contrast, saturation, warmth and shadows, with a debounced live preview.
- **Tune** — gaussian blur (smoothness) and sharpness.
- **Crop** — interactive cropping and rotation via TOCropViewController.
- **Draw** — freehand annotation with the full PencilKit tool picker.
- **Save** — writes the edited image to the photo library and reports the actual result.

## Architecture

Three layers, and every layer is load-bearing.

**`Model/`** — pure Swift. No SwiftUI, no `ObservableObject`, no presentation state.
- `DetailAdjustments`, `TuneAdjustments` — value types describing an edit.
- `EditingTool` — the tools the app offers, and their titles and symbols.
- `ImageProcessor` — an `actor`. The app's only `CIContext` lives here; all filtering runs off the main thread.
- `PhotoLibraryService` — writes to the photo library and throws on failure.

**`Controllers/`** — `@MainActor ObservableObject`s. They own state, call into the model, and publish results.
- `ImageEditController` — the single source of truth for the image being edited. Every tool commits through it.
- `DetailsController`, `TuneImageController` — own their adjustments, drive a debounced preview.
- `DrawingController` — flattens a PencilKit drawing onto the image.

**`View/`** — SwiftUI. Views render published state and report user intent. No view runs image processing, and no view writes to the image directly.

## Requirements

- iOS 18.2+
- Xcode 16+
- [TOCropViewController](https://github.com/TimOliver/TOCropViewController) (Swift Package Manager)

