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
    
    var body: some View {
        VStack(spacing: 20){
            if user != nil {
                Text("Welcome \(String(user!.name))")
                
                Button {
                    try! Auth.auth().signOut()
                    
                    contentModel.checkLogin()
                } label: {
                    Text("Sign Out")
                }
            }
        }
        .onAppear {
            Task {
                user = await contentModel.getUserData()
            }
        }
    }
}

#Preview {
    HomePage()
}
