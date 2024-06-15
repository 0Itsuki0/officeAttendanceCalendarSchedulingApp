//
//  ImageManager.swift
//  ItsukiCalendar
//
//  Created by Itsuki on 2024/05/05.
//


import SwiftUI

class ImageManager: NSObject, ObservableObject {
    struct ImageShareTransferable: Transferable {
        static var transferRepresentation: some TransferRepresentation {
            ProxyRepresentation(exporting: \.image)
        }
        public var image: Image
        public var caption: String
    }
    
    @Published var imageSaved: Int = 0
    @Published var errorMessage: String? = nil

    @MainActor func saveView(_ view: some View, scale: CGFloat) {
        if let uiImage = getUIImage(view, scale: scale) {
            writeToPhotoAlbum(image: uiImage)
        }
    }
    
    @MainActor func getTransferable(_ view: some View, scale: CGFloat, caption: String) -> ImageShareTransferable? {
        if let uiImage = getUIImage(view, scale: scale) {
            return ImageShareTransferable(image: Image(uiImage: uiImage), caption: caption)
        }
        return nil
    }
    
    
    @MainActor private func getUIImage(_ view: some View, scale: CGFloat) -> UIImage? {
        let renderer = ImageRenderer(content: view)
        // make sure and use the correct display scale for this device
        renderer.scale = scale
        if let uiImage = renderer.uiImage {
                return uiImage
        }
        return nil
    }
    
    
    private func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private  func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.errorMessage = "Error saving image: \(error.localizedDescription)!"
        } else {
            imageSaved = imageSaved + 1
        }
    }
}
