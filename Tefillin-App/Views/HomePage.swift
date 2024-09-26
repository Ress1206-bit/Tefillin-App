//
//  ContentView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseAuth

struct HomePage: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @State private var user: User?
    @State private var firstname: String = ""
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        if contentModel.loggedIn && contentModel.agreedToEULA {
            TabView(selection: $selectedTab) {
                GroupFeedView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "house.fill")
                    }
                    .tag(0)
                
                UploadPostView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "plus.app")
                    }
                    .tag(1)
                
                VStack {
                    GroupsView(selectedTab: $selectedTab)
                    Spacer()
                }
                .tabItem {
                    Image(systemName: "person.3.fill")
                }
                .tag(2)
                
                TefillinEducationView()
                    .tabItem {
                        Image(systemName: "book.fill")
                    }
                    .tag(3)
                
                AccountPage()
                    .tabItem {
                        Image(systemName: "person.crop.circle.fill")
                    }
                    .tag(4)
            }
                .tint(Color.accentDarkBlue)
        }
        else {
            LaunchView()
        }
    }
}
