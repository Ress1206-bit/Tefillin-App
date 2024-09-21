//
//  GroupFeedView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/28/24.
//

import SwiftUI

struct GroupFeedView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @Binding var selectedTab: Int
    
    
    @State var groups: [Group] = []
    @State var searchedForGroups: Bool = false
    @State private var selectedIndex = 0
    
    let groupViewScale = 0.75
    
    var body: some View {
        if searchedForGroups {
            if groups.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                    
                    Text("You're not in any groups yet")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    
                    Text("Join a group to stay updated with the latest posts and connect with others.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        selectedTab = 2
                        print("Join a group tapped")
                    }) {
                        Text("Join a Group")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    Task {
                        groups = await contentModel.fetchUserGroups()
                        searchedForGroups = true
                    }
                }
            } else {
                ZStack {
                    
                    Rectangle()
                        .edgesIgnoringSafeArea(.top)
                        .foregroundStyle(Color.accentBlue.opacity(0.1))
                    
                    VStack {
                        TabView(selection: $selectedIndex) {
                            ForEach(groups.indices, id: \.self) { index in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20 * groupViewScale)
                                        .frame(width: 360 * groupViewScale, height: 100 * groupViewScale)
                                        .foregroundColor(Color.accentBlue.opacity(0.1))
                                    GroupView(group: groups[index], groupViewScale: groupViewScale)
                                        .id(groups[index].name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .shadow(color: .white, radius: 1)
                                }
                                .frame(width: 360 * groupViewScale, height: 100 * groupViewScale)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 130)
                        
                        if groups.count > 1 {
                            PageControl(numberOfPages: groups.count, currentPage: $selectedIndex)
                                .id(selectedIndex)
                        }
                        
                        FeedView(groupID: groups[selectedIndex].id)
                            .id(groups[selectedIndex].id)
                        
                        Spacer()
                    }
                    .onAppear {
                        Task {
                            groups = await contentModel.fetchUserGroups()
                            searchedForGroups = true
                        }
                    }
                }
            }
        } else {
            ProgressView()
                .onAppear {
                    Task {
                        groups = await contentModel.fetchUserGroups()
                        searchedForGroups = true
                    }
                }
        }
    }
}

struct PageControl: View {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.accentDarkBlue : Color.gray)
                    .frame(width: 10, height: 10)
            }
        }
    }
}

#Preview {
    GroupFeedView(selectedTab: Binding.constant(0), groups: [])
        .environment(ContentModel())
}
