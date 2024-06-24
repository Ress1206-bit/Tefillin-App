//
//  UploadPostView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct UploadPostView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    
    var body: some View {
        VStack {
            ImageUploadView(selectedImage: $selectedImage)
            
            TextField("Caption", text: $caption)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button(action: {
                if let selectedImage = selectedImage {
                    Task {
                        contentModel.uploadPost(caption: caption, image: selectedImage, groupIds: [])
                    }
                }
            }, label: {
                Text("Upload Image")
            })
        }
        
    }
}

#Preview {
    UploadPostView()
        .environment(ContentModel())
}
