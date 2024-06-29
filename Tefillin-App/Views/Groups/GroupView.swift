//
//  GroupView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/24/24.
//

import SwiftUI

struct GroupView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    var group: Group
    var groupViewScale: Double
    
    @State var name: String?
    @State var image: UIImage?
    @State var memberCount: Int = 0
    @State var postCount: Int = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20 * groupViewScale)
                .frame(width: 360 * groupViewScale, height: 100 * groupViewScale)
                .foregroundStyle(.white)
                .shadow(radius: 3 * groupViewScale)
            HStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80 * groupViewScale, height: 80 * groupViewScale)
                        .clipShape(RoundedRectangle(cornerRadius: 20 * groupViewScale))
                        .padding([.top, .bottom])
                        .padding(.leading, 10 * groupViewScale)
                }
                else {
                    RoundedRectangle(cornerRadius: 20 * groupViewScale)
                        .foregroundStyle(.white)
                        .frame(width: 80 * groupViewScale, height: 80 * groupViewScale)
                        .padding([.top, .bottom], 16 * groupViewScale)
                        .padding(.leading, 10 * groupViewScale)
                }
                Spacer()
                VStack {
                    Text(name ?? "")
                        .font(.system(size: 22 * groupViewScale))
                        .bold()
                    HStack{
                        Text("Members: \(memberCount)")
                            .font(.system(size: 17 * groupViewScale))
                        Text("Wraps: \(postCount)")
                            .font(.system(size: 17 * groupViewScale))
                    }
                    .padding(.top, 1 * groupViewScale)
                }
                
                Spacer()
            }
        }
        .frame(width: 350 * groupViewScale, height: 100 * groupViewScale)
        .padding(.horizontal, 16 * groupViewScale)
        .padding(.top, 5 * groupViewScale)
        .onAppear {
            Task {
                self.name = group.name
                self.memberCount = group.members.count
                self.postCount = group.postIds.count
                let image = await contentModel.fetchImageFromPath(path: group.imageReference)
                self.image = image
            }
        }
    }
}

