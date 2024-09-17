//
//  CameraProvider.swift
//  Pingtype
//
//  Created by Peter Burkimsher on 11/11/23.
//

import MobileCoreServices
import UIKit

class CameraProvider: NSObject {

    enum PhotoLibraryTypes {
        case photoLibrary, savedPhotosAlbum
        var casted: UIImagePickerController.SourceType {
            switch self {
            case .photoLibrary: return UIImagePickerController.SourceType.photoLibrary
            case .savedPhotosAlbum: return UIImagePickerController.SourceType.savedPhotosAlbum
            }
        }
    }

    public typealias SourceType = UIImagePickerController.SourceType
    public typealias ImagePicker = UIImagePickerController
    public typealias Delegate = UINavigationControllerDelegate & UIImagePickerControllerDelegate

    private let delegate: Delegate

    init(delegate: Delegate) {
        self.delegate = delegate
    }

    // MARK: - Public

    public func getImagePicker(source: PhotoLibraryTypes,
                               canEditPhotos: Bool = true,
                               onlyImages: Bool = false) throws -> ImagePicker {

        do {
            return try getBaseController(
                source: source.casted,
                allowsEditing: canEditPhotos,
                onlyImages: onlyImages
            )
        } catch {
            throw error
        }
    }

    public func getCamera(canEditPhotos: Bool = true,
                          onlyImages: Bool = false) throws -> ImagePicker {

        do {
            let picker = try getBaseController(
                source: .camera,
                allowsEditing: canEditPhotos,
                onlyImages: onlyImages
            )

            if UIImagePickerController.isCameraDeviceAvailable(.rear) {
                picker.cameraDevice = .rear
            } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
                picker.cameraDevice = .front
            } else {
                throw "No known camera type available"
            }

            picker.showsCameraControls = true
            return picker
        } catch {
            throw error
        }
    }

    // MARK: - Private

    private func getBaseController(source: SourceType,
                                   allowsEditing: Bool,
                                   onlyImages: Bool) throws -> ImagePicker {

        guard UIImagePickerController.isSourceTypeAvailable(source) else {
            throw "Requested source not available"
        }

        let picker = UIImagePickerController()
        let imageType = kUTTypeImage as String
        picker.sourceType = source
        picker.allowsEditing = allowsEditing
        picker.delegate = self.delegate

        if onlyImages,
           let mediaTypes = UIImagePickerController.availableMediaTypes(for: source),
           mediaTypes.contains(imageType){
            picker.mediaTypes = [imageType]
        }

        return picker
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

