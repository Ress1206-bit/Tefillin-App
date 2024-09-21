//
//  GroupsView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/24/24.
//

import SwiftUI

struct GroupsView: View {
    
    @Environment(ContentModel.self) private var contentModel
    @Environment(\.colorScheme) private var colorScheme
    @Binding var selectedTab: Int
    
    @State var search: String = ""
    @State var groups: [Group] = []
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.accentDarkBlue)
                TextField("Search for Group", text: $search)
                    .textFieldStyle(.plain)
                    .foregroundColor(.accentDarkBlue)
                    .padding(10)
                    .background(colorScheme == .light ? .white : .black)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal)
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
                .font(.custom("Avenir-Heavy", size: 18))
                .foregroundColor(colorScheme == .light ? Color.accentDarkBlue : .white)
                .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(groups, id: \.self) { group in
                        GroupView(group: group, groupViewScale: 1)
                            .padding()
                            .background(Color.accentBlue.opacity(0.1))
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                            .onTapGesture {
                                contentModel.joinGroup(groupID: group.id)
                                selectedTab = 0
                            }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [colorScheme == .light ? .white : .black, Color.accentBlue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
    }
}

#Preview {
    GroupsView(selectedTab: Binding.constant(1))
        .environment(ContentModel())
}
