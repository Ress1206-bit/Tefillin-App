//
//  PostView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/24/24.
//

import SwiftUI
import FirebaseAuth

struct PostView: View {
    @Environment(ContentModel.self) private var contentModel
    @Environment(\.colorScheme) private var colorScheme
    
    @State var post: Post?
    @State var username: String = "username"
    @State var image: UIImage?
    @State var caption: String = "This is my image!"
    
    @State private var showingComments = false
    @State private var sheetHeight = 0.7
    @State var heartFill = false
    @State private var showBlockConfirmation = false
    @State private var showReportAlert = false
    @State private var reportReason: String = ""

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.accentDarkBlue)
                    .font(.system(size: 25))
                Text(username)
                    .font(.headline)
                    .foregroundColor(.accentDarkBlue)
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        showBlockConfirmation = true
                    } label: {
                        Label("Block User", systemImage: "hand.raised.fill")
                    }
                    Button {
                        showReportAlert = true
                    } label: {
                        Label("Report Post", systemImage: "exclamationmark.triangle.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 20))
                        .foregroundColor(.accentDarkBlue)
                        .padding(.trailing)
                }
            }
            .padding(.leading)
            
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .clipped()
                        .shadow(radius: 1)
                        .onTapGesture(count: 2) {
                            heartFill = true
                        }

                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 400)
                        .foregroundStyle(.gray.opacity(0.1))
                        .shadow(radius: 1)
                        .onTapGesture(count: 2) {
                            heartFill = true
                        }
                }
            }
            
            HStack {
                Text(caption)
                    .font(.body)
                    .foregroundColor(.accentDarkBlue)
                    .padding(.leading, 40)
                Spacer()
                Image(systemName: "message")
                    .padding(.trailing, 30)
                    .font(.system(size: 25))
                    .foregroundColor(.accentBlue)
                    .onTapGesture {
                        showingComments = true
                    }
            }
        }
        .frame(minHeight: 510)
        .padding(.vertical, 15)
        .background(RoundedRectangle(cornerRadius: 12).fill(colorScheme == .light ? .white : .black))
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingComments) {
            CommentsView(isPresented: $showingComments, postID: post?.id, sheetHeight: $sheetHeight)
                .presentationDetents([.fraction(sheetHeight)])
        }
        .alert("Block User", isPresented: $showBlockConfirmation) {
            Button("Block", role: .destructive) {
                if let post = post {
                    contentModel.blockUser(post.userId)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to block this user? You won't see any content from them in the future.")
        }
        .alert("Report Post", isPresented: $showReportAlert) {
            TextField("Reason (optional)", text: $reportReason)
            Button("Report", role: .destructive) {
                if let post = post {
                    contentModel.reportPost(post, reason: reportReason)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to report this post? Reported content will be reviewed within 24 hours. If deemed objectionable, the content will be removed, and the user may be ejected from the platform.")
        }
        .onAppear {
            Task {
                if let post = post {
                    username = await contentModel.fetchUserInfo(userID: post.userId).username
                    caption = post.caption
                    image = await contentModel.fetchImageFromPath(path: post.imageReference)
                }
            }
        }
    }
}

#Preview {
    PostView()
        .environment(ContentModel())
}
