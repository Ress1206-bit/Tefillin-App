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
    
    @Binding var selectedTab: Int
    
    @State var groups: [Group] = []
    @State var selectedGroupIDs: [String] = []
    @State private var showGroupSelector = false
    
    @State private var selectedImage: UIImage?
    @State private var caption: String = ""
    @State var searchedForGroupsUpload: Bool = false
    @State private var showAlert = false
    
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
                        selectedTab = 2
                        print("Join a group tapped")
                    }) {
                        Text("Join a Group")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentBlue)
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
                
                ZStack {
                    
                    Rectangle()
                        .edgesIgnoringSafeArea(.top)
                        .foregroundStyle(Color.accentBlue.opacity(0.3))
                    
                    
                    VStack(spacing: 20) {
                        ImageUploadView(selectedImage: $selectedImage)
                        
                        TextField("Enter a caption...", text: $caption)
                            .font(.custom("Avenir", size: 18))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showGroupSelector = true
                        }) {
                            Text(selectedGroupIDs.isEmpty ? "Select Groups" : "Groups Selected (\(selectedGroupIDs.count))")
                                .font(.custom("Avenir-Heavy", size: 18))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedGroupIDs.isEmpty ? Color.accentDarkBlue : Color.accentDarkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            if selectedGroupIDs.isEmpty {
                                showAlert = true
                            } else if let selectedImage = selectedImage {
                                Task {
                                    contentModel.uploadPost(caption: caption, image: selectedImage, groupIds: selectedGroupIDs)
                                }
                            }
                        }) {
                            Text("Upload Post")
                                .font(.custom("Avenir-Heavy", size: 18))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedImage == nil || selectedGroupIDs.isEmpty ? Color.gray.opacity(0.7) : Color.accentBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .disabled(selectedImage == nil || selectedGroupIDs.isEmpty)
                        
                        Spacer()
                    }
                    .sheet(isPresented: $showGroupSelector) {
                        GroupSelectorView(groups: groups, selectedGroupIDs: $selectedGroupIDs)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Select a Group"), message: Text("Please select at least one group to post to."), dismissButton: .default(Text("OK")))
                    }
                    .onDisappear {
                        selectedGroupIDs = []
                        showGroupSelector = false
                        
                        selectedImage = nil
                        caption = ""
                        searchedForGroupsUpload = false
                        showAlert = false
                    }
                    
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
                        .font(.custom("Avenir-Heavy", size: 18))
                        .padding()
                        .background(Color.accentBlue)
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
                .font(.custom("Avenir", size: 16))
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
    UploadPostView(selectedTab: Binding.constant(0))
        .environment(ContentModel())
}
