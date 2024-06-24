//
//  LaunchView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    
    @Environment(ContentModel.self) private var contentModel
    
    @State var loginFormShowing = false
    @State var createFormShowing = false
    
    
    var body: some View {
        
        if contentModel.loggedIn == false {
            
            VStack {
                
                //Sign in button
                Button {
                    //Show Login Form
                    loginFormShowing = true
                } label: {
                    Text("Sign In")
                }
                .sheet(isPresented: $loginFormShowing, onDismiss: contentModel.checkLogin) {
                    LoginForm(formShowing: $loginFormShowing)
                }
                
                //Create account button
                Button {
                    createFormShowing = true
                } label: {
                    Text("Create Account")
                }
                .sheet(isPresented: $createFormShowing, onDismiss: contentModel.checkLogin) {
                    CreateAccountForm(formShowing: $createFormShowing)
                }

            }
            .onAppear {
                contentModel.checkLogin()
            }
        }
        else {
            //Show logged in View
            HomePage()
        }
    }
    
    
}

#Preview {
    LaunchView()
        .environment(ContentModel())
}
