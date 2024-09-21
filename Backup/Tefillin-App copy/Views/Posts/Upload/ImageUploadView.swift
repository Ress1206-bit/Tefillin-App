//
//  ImageUploadView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import PhotosUI

import SwiftUI
import PhotosUI
import UIKit

struct ImageUploadView: View {
    @Binding var selectedImage: UIImage?
    @State private var newImage: PhotosPickerItem?
    @State private var isCameraPresented = false

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                PhotosPicker(selection: $newImage, matching: .images) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 300, height: 400)
                            VStack {
                                Text("Add Photo")
                                    .font(.title)
                                    .padding(.top, 10)
                                Image(systemName: "photo")
                                    .font(.system(size: 80))
                                    .padding(.bottom, 10)
                            }
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                        .shadow(radius: 3)
                    }
                }
                .onChange(of: newImage) { _, _ in
                    Task {
                        if let newImage {
                            if let data = try? await newImage.loadTransferable(type: Data.self) {
                                if let image = UIImage(data: data) {
                                    selectedImage = image
                                }
                            }
                        }
                        newImage = nil
                    }
                }
            }
        }
        .padding()
    }
}

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
