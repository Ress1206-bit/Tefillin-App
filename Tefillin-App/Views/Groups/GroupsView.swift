//
//  GroupsView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/24/24.
//

import SwiftUI

struct GroupsView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @State var search: String = ""
    @State var groups: [Group] = []
    
    var body: some View {
        VStack {
            TextField("Search for Group", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: search, {
                    Task {
                        groups = []
                        contentModel.retrievedGroups = []
                        await contentModel.fetchGroupBySearch(searchField: search)
                        groups = contentModel.retrievedGroups
                    }
                })
                .onAppear {
                    Task {
                        groups = []
                        contentModel.retrievedGroups = []
                        await contentModel.fetchGroupBySearch(searchField: search)
                        groups = contentModel.retrievedGroups
                        
                    }
                }
            Divider()
            Text("Tap on group to join.")
            Divider()
            ScrollView {
                ForEach(groups, id: \.self){ group in
                    GroupView(group: group, groupViewScale: 1)
                        .onTapGesture(perform: {
                            contentModel.joinGroup(groupID: group.id)
                        })
                }
            }
            .scrollContentBackground(.hidden)
            Spacer()
        }
    }
}

#Preview {
    GroupsView()
        .environment(ContentModel())
}
