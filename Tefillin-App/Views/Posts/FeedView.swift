//
//  FeedView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/24/24.
//

import SwiftUI

struct FeedView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    var groupID: String?
    
    @State var posts: [Post] = []
    @State var endOfFeed = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(posts, id: \.self) { post in
                    PostView(post: post)
                        .padding(.horizontal)
                        .background(Color.accentBlue.opacity(0))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                
                if !endOfFeed {
                    ProgressView()
                        .padding(.top, 30)
                        .background(GeometryReader { progressGeo in
                            Color.clear
                                .onChange(of: progressGeo.frame(in: .global).minY, { oldValue, newValue in
                                    
                                    if newValue < 800 && oldValue >= 800 {
                                        Task {
                                            if let groupID = groupID {
                                                let newPosts = await contentModel.fetchPosts(amountToGet: 2, amountReceived: posts.count, groupID: groupID)
                                                
                                                if newPosts.count == 0 {
                                                    endOfFeed.toggle()
                                                } else {
                                                    posts.append(contentsOf: newPosts)
                                                }
                                            }
                                        }
                                    }
                                })
                        })
                } else {
                    Text("Bottom of the feed.")
                        .font(.headline)
                        .foregroundColor(.accentDarkBlue)
                        .padding(.vertical, 30)
                }
            }
            .padding(.top)
        }
        .background {
            Color.accentBlue.opacity(0.1).ignoresSafeArea()
        }
        .onAppear {
            Task {
                posts = []
                endOfFeed = false
                
                if let groupID = groupID {
                    posts = await contentModel.fetchPosts(amountToGet: 2, amountReceived: 0, groupID: groupID)
                }
            }
        }
        .onDisappear {
            posts = []
            endOfFeed = false
        }
    }
}

#Preview {
    FeedView()
        .environment(ContentModel())
}
