//
//  testing.swift
//  Tefillin-App
//
//  Created by Adam Ress on 8/17/24.
//

import SwiftUI
import FirebaseAuth

struct AccountPage: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @State private var user: User?
    @State private var wrapCount: Int = 0
    @State private var posts: [Post] = []
    @State private var postImages: [String: UIImage] = [:]
    @State private var selectedPost: Post?
    
    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            
            HStack {
                Text(user?.username ?? "")
                    .padding(.leading)
                    .font(.largeTitle)
                    
                Spacer()
                Button(action: {
                    try! Auth.auth().signOut()
                    contentModel.checkLogin()
                }) {
                    Text("Sign Out")
                        .font(.custom("Avenir-Heavy", size: 16))
                        .frame(width: 150)
                        .foregroundColor(.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            
            VStack(alignment: .leading) {
                Text("My Posts")
                    .font(.custom("HelveticaNeue-Bold", size: 24))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .padding(.leading, 15)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(posts, id: \.self) { post in
                            ZStack {
                                if let image = postImages[post.id ?? ""] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150*0.75, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .clipped()
                                        .shadow(radius: 1)
                                        .onTapGesture {
                                            selectedPost = post
                                        }
                                } else {
                                    
                                    Rectangle()
                                        .fill(Color.accentBlue.opacity(0.2))
                                        .aspectRatio(0.75, contentMode: .fit)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 10)
        }
        .padding(.top, 40)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .sheet(item: $selectedPost) { post in
            PostView(post: post)
        }
        .onAppear {
            Task {
                user = await contentModel.getUserData()
                wrapCount = user?.postIds.count ?? 0
                if let user = user {
                    posts = await contentModel.fetchUserPosts(userPostIds: user.postIds)
                    

                    for post in posts {
                        if let image = await contentModel.fetchImageFromPath(path: post.imageReference) {
                            postImages[post.id ?? ""] = image
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AccountPage()
        .environment(ContentModel())
}
