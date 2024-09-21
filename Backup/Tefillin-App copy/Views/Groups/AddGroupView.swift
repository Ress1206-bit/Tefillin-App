//
//  AddGroupView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/24/24.
//

import SwiftUI
import PhotosUI

struct AddGroupView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    
    @State var selectedImage: UIImage?
    @State private var newImage: PhotosPickerItem?

    @State var groupName: String = ""
    
    
    var body: some View {
        VStack {
            HStack {
                PhotosPicker(selection: $newImage, matching: .images) {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.leading)
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
                TextField("Group Name", text: $groupName)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .padding(.trailing)
                
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 360, height: 100)
                    .foregroundStyle(.white)
                    .shadow(radius: 3)
                HStack {
                    if selectedImage == nil {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 80, height: 80)
                            .padding([.top, .bottom])
                            .padding(.leading, 10)
                    }
                    else {
                        Image(uiImage: selectedImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding([.top, .bottom])
                            .padding(.leading, 10)
                    }
                    Spacer()
                    VStack {
                        Text("\(groupName)")
                            .font(.system(size: 22))
                            .bold()
                        HStack{
                            Text("Members: 0")
                            Text("Wraps: 0")
                        }
                        .padding(.top, 1)
                    }
                    
                    Spacer()
                }
            }
            .frame(width: 300, height: 100)
            .padding()
            
            Button(action: {
                if let image = selectedImage {
                    contentModel.createGroup(groupName: groupName, image: image)
                }
            }, label: {
                Text("Create Group")
            })
        }
    }
}

#Preview {
    AddGroupView()
        .environment(ContentModel())
}
