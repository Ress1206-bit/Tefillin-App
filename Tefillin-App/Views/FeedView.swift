//
//  FeedView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/24/24.
//

import SwiftUI

struct FeedView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @State var posts: [Post] = []
    @State var username: String?
    @State var isLoading = false
    @State var endOfFeed = false
    
    var body: some View {
        
        ScrollView {
            VStack {
                ForEach(posts, id: \.self){ post in
                    PostView(post: post)
                }
                
                if endOfFeed == false {
                    ProgressView()
                        .padding(.top, 30)
                        .background(GeometryReader { progressGeo in
                            Color.clear
                                .onChange(of: progressGeo.frame(in: .global).minY, { oldValue, newValue in
                                    if newValue < 800 && oldValue >= 800 {
                                        Task {
                                            await contentModel.fetchPosts(amount: 2)
                                            if posts.count == contentModel.retrievedPosts.count {
                                                endOfFeed = true
                                            }
                                            else {
                                                posts = contentModel.retrievedPosts
                                            }
                                        }
                                    }
                                })
                        })
                }
                else {
                    Text("Bottom of the feed.")
                        .padding(.top, 30)
                }
            }
        }
        .onAppear {
            Task {
                
                let firstLoadAmount = 3
                
                await contentModel.fetchPosts(amount: 3)
                posts = contentModel.retrievedPosts
                
                if posts.count < firstLoadAmount {
                    endOfFeed = true
                }
               
            }
            
        }
        .onDisappear {
            contentModel.retrievedPosts = []
            posts = []
            endOfFeed = false
        }
    }
        
}

#Preview {
    FeedView()
        .environment(ContentModel())
}
