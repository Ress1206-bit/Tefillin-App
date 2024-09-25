//
//  Comments.swift
//  Tefillin-App
//
//  Created by Adam Ress on 8/6/24.
//


import SwiftUI

struct CommentsView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @Binding var isPresented: Bool
    @State var comments: [Comment] = []
    @State var commentText: String = ""
    @State var postID: String?
    
    @State private var showingTypeMode = false
    @State private var showReportAlert = false
    @State private var selectedComment: Comment?
    @State private var reportReason: String = ""
    
    @Binding var sheetHeight: Double
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
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
                                VStack(alignment: .leading) {
                                    Text(comment.username) //.name
                                        .fontWeight(.bold)
                                        .padding(.top, 2)
                                    Text(comment.text)
                                        .padding(.leading, 5)
                                }
                                Spacer()
                                Button(action: {
                                    selectedComment = comment
                                    showReportAlert = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .padding(.trailing)
                                }
                            }
                            .padding(.leading, 10)
                        }
                    }
                }
                
                HStack {
                    TextField("Add comment...", text: $commentText, onCommit: {
                        showingTypeMode = false
                        sheetHeight = 0.7
                        commentText = "Add comment..."
                    })
                        .foregroundStyle(.gray)
                        .frame(width: 200)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6)))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .onTapGesture {
                            showingTypeMode = true
                            sheetHeight = 0.7
                        }
                    
                    if showingTypeMode {
                        Button(action: {
                            if postID != nil {
                                if commentText != "" && commentText != " " {
                                    contentModel.addCommentToPost(text: commentText, postID: postID!)
                                }
                            }
                            
                            Task {
                                do {
                                    let comments = try await contentModel.fetchCommentsForPost(postID: postID!)
                                    self.comments = comments
                                } catch {
                                    print("Error fetching comments: \(error)")
                                }
                                
                                isPresented = false
                                isPresented = true
                                commentText = ""
                            }
                
                        }, label: {
                            Image(systemName: "paperplane.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentBlue)
                                .cornerRadius(20)
                        })
                        .frame(width: 40, height: 40)
                        .shadow(radius: 3)
                        .padding(.trailing, 30)
                    }
                }
                .padding()
                
                if showingTypeMode {
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Report Comment", isPresented: $showReportAlert) {
            TextField("Reason (optional)", text: $reportReason)
            Button("Report", role: .destructive) {
                if let comment = selectedComment {
                    contentModel.reportComment(comment, reason: reportReason)
                }
                reportReason = ""
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to report this comment? Reported content will be reviewed within 24 hours. If deemed objectionable, the content will be removed, and the user may be ejected from the platform.")
        }
        .onAppear {
            if postID != nil {
                Task {
                    do {
                        let comments = try await contentModel.fetchCommentsForPost(postID: postID!)
                        self.comments = comments
                    } catch {
                        print("Error fetching comments: \(error)")
                    }
                }
            }
        }
        .onDisappear {
            sheetHeight = 0.7
        }
    }
}

//#Preview {
//    CommentsView(isPresented: true, comments: Bin)
//}
