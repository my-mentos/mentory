//
//  ImagePicker.swift
//  Mentory
//
//  Created by 구현모 on 11/18/25.
//
import SwiftUI
import PhotosUI


// MARK: UIKit에서 제공하는 Source를
public struct ImagePicker: UIViewControllerRepresentable {
    @Binding public var imageData: Data?
    @Environment(\.dismiss) public var dismiss
    public var sourceType: UIImagePickerController.SourceType

    public init(imageData: Binding<Data?>, sourceType: UIImagePickerController.SourceType) {
        self._imageData = imageData
        self.sourceType = sourceType
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.imageData = editedImage.jpegData(compressionQuality: 0.8)
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.imageData = originalImage.jpegData(compressionQuality: 0.8)
            }
            parent.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

public struct PhotosPicker: UIViewControllerRepresentable {
    @Binding public var imageData: Data?
    @Environment(\.dismiss) public var dismiss

    public init(imageData: Binding<Data?>) {
        self._imageData = imageData
    }

    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotosPicker

        init(_ parent: PhotosPicker) {
            self.parent = parent
        }

        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()

            guard let result = results.first else { return }

            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.imageData = image.jpegData(compressionQuality: 0.8)
                    }
                }
            }
        }
    }
}
