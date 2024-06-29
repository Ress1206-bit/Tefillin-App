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
    
    @State var groups: [Group] = []
    @State var selectedGroupIDs: [String] = []
    @State private var showGroupSelector = false
    
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State var searchedForGroupsUpload: Bool = false
    
    var body: some View {
        if searchedForGroupsUpload {
            if groups.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                    
                    Text("You're not in any groups yet")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    
                    Text("Join a group to stay updated with the latest posts and connect with others.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        // Action to join a group
                        print("Join a group tapped")
                    }) {
                        Text("Join a Group")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    Task {
                        groups = await contentModel.fetchUserGroups()
                        searchedForGroupsUpload = true
                    }
                }
            }
            else {
                VStack {
                    ImageUploadView(selectedImage: $selectedImage)
                    
                    TextField("Caption", text: $caption)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button(action: {
                        showGroupSelector = true
                    }) {
                        Text("Select Groups to Post to")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: {
                        if let selectedImage = selectedImage {
                            Task {
                                contentModel.uploadPost(caption: caption, image: selectedImage, groupIds: selectedGroupIDs)
                            }
                        }
                    }, label: {
                        Text("Upload Image")
                    })
                }
                .sheet(isPresented: $showGroupSelector) {
                    GroupSelectorView(groups: groups, selectedGroupIDs: $selectedGroupIDs)
                }
            }
        }
        else {
            ProgressView()
                .onAppear {
                    Task {
                        groups = await contentModel.fetchUserGroups()
                        searchedForGroupsUpload = true
                    }
                }
        }
        
    }
}

struct GroupSelectorView: View {
    var groups: [Group]
    @Binding var selectedGroupIDs: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    selectedGroupIDs = groups.map { $0.id }
                }) {
                    Text("Select All")
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                ScrollView {
                    VStack {
                        ForEach(groups, id: \.self) { group in
                            MultipleSelectionRow(group: group, selectedGroupIDs: $selectedGroupIDs)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Select Groups", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct MultipleSelectionRow: View {
    var group: Group
    @Binding var selectedGroupIDs: [String]
    
    var isSelected: Bool {
        selectedGroupIDs.contains(group.id)
    }
    
    var body: some View {
        HStack {
            Text(group.name)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelected {
                selectedGroupIDs.removeAll(where: { $0 == group.id })
            } else {
                selectedGroupIDs.append(group.id)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}


#Preview {
    UploadPostView()
        .environment(ContentModel())
}
