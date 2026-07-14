# Refactor notes

Everything visual is unchanged. Every `body` renders the same pixels: same materials,
gradients, spacings, corner radii, symbols, animations, haptics. What changed is what
the views *call*.

---

## Files deleted

| File | Why |
|---|---|
| `Item.swift` | Xcode SwiftData template leftover. Never used. |
| `Model/DrawingModel.swift` | Never referenced. `DrawOnImageView` reimplemented it inline. |
| `Model/FilterPreset.swift` | Never referenced by any view. See "Removed capability" below. |
| `Model/ImageEditModel.swift` | Was a view model living in the model layer. Replaced by `ImageEditController`. |
| `Model/TuneImageModel.swift` | Mixed settings with images. Replaced by `TuneAdjustments`. |
| `Controllers/CropController.swift` | Never wired up. `CropView.Coordinator` was always the real delegate. |
| `Controllers/ToolsController.swift` | Never instantiated. Its `ToolOption` enum became `Model/EditingTool.swift`. |
| `Controllers/DetailsController .swift` | Trailing space in the filename. Recreated as `DetailsController.swift`. |
| `Controllers/GalleryPicker.swift` | A `UIViewControllerRepresentable` is a view. Moved to `View/`. |
| `vividify_3_0App.swift` | Renamed to `Vividify3App.swift`; SwiftData container removed. |

Xcode 16 synchronized folders means none of this required touching `project.pbxproj`.

---

## Bugs fixed

1. **`TuneImageController` infinite feedback loop.** A Combine sink on `$model` triggered
   work that wrote back into `model`, which republished `$model`, which retriggered the
   sink. It reprocessed the image every ~100ms forever. Combine is gone; a single
   cancellable `Task` does the debouncing and the result lands in a separate property.

2. **Core Image on the main thread.** `Timer.scheduledTimer` fires on the main runloop, so
   `createCGImage` was blocking the UI — and the `DispatchQueue.main.async` around the
   *assignment* was backwards. All processing now happens inside the `ImageProcessor` actor.

3. **`DetailsView` filtered inside `body`.** `Image(uiImage: controller.applyFilters(to: image))`
   re-ran the whole Core Image pipeline synchronously on every body evaluation — every slider
   tick. Meanwhile the controller's debounced `filteredImage` was never read. The view now
   renders `controller.previewImage`.

4. **Saving always reported success.** `UIImageWriteToSavedPhotosAlbum` was called with a nil
   completion selector, then `saveSuccess = true` was set unconditionally after a one-second
   delay. Denied permissions still showed "Image saved successfully!". Now uses
   `PHPhotoLibrary` and surfaces the real error.

5. **`Task.detached` touching a live `PKCanvasView`.** `saveDrawingToImage()` read `canvasView.drawing`
   and `canvasView.bounds` — UIView state — from a background thread, and ran
   `UIGraphicsImageRenderer` off the main actor. The canvas is now read on the main actor and
   only value types cross into the processor.

6. **`processedImage` was permanently nil.** `setSelectedImage` was never called (the picker bound
   straight to `selectedImage`), so `processedImage` never got set and the app worked by luck of
   the `??` fallback. There is now one image property.

7. **Blur grew the image.** Rendering from `outputImage.extent` after `gaussianBlur` produced an
   image larger than the source on every pass. Now the pre-filter extent is captured and the render
   is cropped back to it, and the input is `clampedToExtent()` so the blur doesn't sample past the
   edge and darken the border.

8. **Two `CIContext`s.** `ImageProcessor` had one; `TuneImageController` quietly built another.
   There is now exactly one, owned by the actor, with a genuinely `private init`.

9. **`CameraPicker` crashed on simulator.** `sourceType = .camera` was set unconditionally. Now
   guarded with `isSourceTypeAvailable`.

10. **`TuneImageView` constructed its controller with `UIImage()`** when the binding was nil —
    an empty image that `CIImage(image:)` can't consume. The controller is now started in `.onAppear`.

11. Duplicate `import SwiftUI` in `ContentView`. Deprecated `allowsFingerDrawing`. A `deinit`
    reaching into a `@Binding`.

---

## Project file change

I added one build setting, in both Debug and Release:

```
INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription = "Vividify saves your edited photos to your library.";
```

`PHPhotoLibrary.requestAuthorization(for: .addOnly)` requires it. Without it the app traps on save.
This is the only edit to `project.pbxproj`.

---

## Removed capability — read this

Two things were deleted because no UI reaches them, and you told me not to add UI:

- **Filter presets.** `FilterPreset` defined six presets (Vivid, Dramatic, Warm, Cool, Vintage).
  `DetailsController.applyPreset` existed. No view ever called it. Wiring them up means adding a
  horizontal preset strip to `DetailsView` — say the word and I'll do it.
- **Undo / redo.** `editHistory`, `currentHistoryIndex`, `undo()`, `redo()` had zero call sites.
  There is no undo button anywhere in the UI. Bringing it back is a toolbar button plus ~20 lines
  in `ImageEditController`.
- **`clarity`, `vignette`, `structure`, `noiseReduction`** on the old `TuneImageModel`. Two had no
  sliders; two had no implementation at all. Every property on `TuneAdjustments` now maps to a
  control that exists.

All three are one commit away if you want them. They were deleted, not lost — `git revert` has them.
