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
    
    @State var name: String?
    @State var image: UIImage?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 360, height: 100)
                .foregroundStyle(.white)
                .shadow(radius: 3)
            HStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding([.top, .bottom])
                        .padding(.leading, 10)
                }
                else {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 80, height: 80)
                        .padding([.top, .bottom])
                        .padding(.leading, 10)
                }
                Spacer()
                VStack {
                    Text(name ?? "")
                        .font(.system(size: 22))
                        .bold()
                    HStack{
                        Text("Members: 0")
                        Text("Wraps: 0")
                    }
                    .padding(.top, 1)
                }
                
                Spacer()
            }
        }
        .frame(width: 350, height: 100)
        .padding(.horizontal)
        .padding(.top, 5)
        .onAppear {
            Task {
                self.name = group.name
                let image = await contentModel.fetchImageFromPath(path: group.imageReference)
                self.image = image
            }
        }
    }
}

