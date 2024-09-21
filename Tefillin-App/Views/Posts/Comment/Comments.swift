//
//  Comments.swift
//  Tefillin-App
//
//  Created by Adam Ress on 8/6/24.
//

import SwiftUI

struct CommentsView: View {
    @Binding var isPresented: Bool
    @Binding var comments: [Comment]
    @State var commentText: String = ""
    
    var body: some View {
        NavigationView {
            VStack{
                ZStack{
                    HStack {
                        Spacer()
                        Text("\(comments.count) comments")
                            .fontWeight(.medium)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresented = false
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                                .font(.system(size: 15))
                                .padding()
                        })
                    }
                }
                ScrollView {
                    ForEach(comments) { comment in
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.gray)
                                    .padding(.trailing, 8)
                                    .padding(.leading, 5)
                                VStack(alignment: .leading) {
                                    Text(comment.username)
                                        .fontWeight(.bold)
                                        .padding(.top, 2)
                                    Text(comment.text)
                                        .padding(.trailing, 2)
                                }
                                Spacer()
                                VStack {
                                    Button(action: {
                                        // Add like action
                                        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
                                            comments[index].likes += 1
                                        }
                                    }) {
                                        Image(systemName: "heart")
                                            .foregroundStyle(.black)
                                    }
                                    Text("\(comment.likes)")
                                }
                                .padding(.trailing)
                            }
                            Button(action: {
                                addReply(to: comment)
                            }) {
                                Text("Reply")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 60)
                            }
                            ForEach(comment.replies) { reply in
                                HStack {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundStyle(.gray)
                                        .padding(.leading, 50)
                                    VStack(alignment: .leading) {
                                        Text(reply.username)
                                            .fontWeight(.semibold)
                                            .padding(.top, 2)
                                        Text(reply.text)
                                    }
                                }
                            }
                            
                        }
                    }
                }
                
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                        .padding()
                    
                    TextField("Add comment...", text: $commentText, onCommit: {
                        addComment()
                    })
                        .textFieldStyle(.plain)
                    Button(action: {
                        addComment()
                    }) {
                        Text("Post")
                    }
                    .padding(.trailing)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    func addComment() {
        guard !commentText.isEmpty else { return }
        let newComment = Comment(username: "User \(comments.count + 1)", text: commentText, likes: 0, replies: [])
        comments.append(newComment)
        commentText = ""
    }
    
    func addReply(to comment: Comment) {
        guard !commentText.isEmpty else { return }
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            let newReply = Comment(username: "User \(comments.count + 1)", text: commentText, likes: 0, replies: [])
            comments[index].replies.append(newReply)
            commentText = ""
        }
    }
}

//#Preview {
//    CommentsView(isPresented: true, comments: Bin)
//}
