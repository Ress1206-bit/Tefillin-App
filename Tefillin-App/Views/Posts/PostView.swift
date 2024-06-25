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
    
    @State var post: Post?
    
    @State var username: String = "username"
    @State var image: UIImage?
    @State var caption: String = "This is my image!"
    
    
    @State var heartFill = false
    
    var body: some View {
        VStack {
            Divider()
                .padding(.top, 20)
            HStack {
                Image(systemName: "person.crop.circle.fill")
                Text(username)
                Spacer()
                //Text(post?.timePosted.description ?? "")
            }
            .padding(.leading)
            .padding(.vertical, 3)
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 1)
                        .onTapGesture(count: 2) {
                            heartFill = true
                        }

                }
                else {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 300, height: 300)
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                        .onTapGesture(count: 2) {
                            heartFill = true
                        }
                }
            }
            HStack {
                Text(caption)
                    .padding(.leading, 40)
                    .padding(.top, 5)
                Spacer()
                if !heartFill {
                    Image(systemName: "heart")
                        .padding(.top, 5)
                        .padding(.trailing, 50)
                        .font(.system(size: 25))
                        .onTapGesture {
                            heartFill.toggle()
                        }
                } else {
                    Image(systemName: "heart.fill")
                        .padding(.top, 5)
                        .padding(.trailing, 50)
                        .font(.system(size: 25))
                        .foregroundStyle(.red)
                        .onTapGesture {
                            heartFill.toggle()
                        }
                }
                
            }
        }
        .onAppear {
            Task{
                if let post = post{
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
