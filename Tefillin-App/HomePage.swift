//
//  ContentView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseAuth

struct HomePage: View {
    
    @Binding var loggedIn: Bool
    
    @State private var firstname: String = ""
    
    var body: some View {
        VStack(spacing: 20){
            Text("Welcome")
            
            Button {
                try! Auth.auth().signOut()
                
                loggedIn = false
            } label: {
                Text("Sign Out")
            }

        }
    }
}

#Preview {
    HomePage(loggedIn: Binding.constant(true))
}
