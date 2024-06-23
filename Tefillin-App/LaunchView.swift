//
//  LaunchView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    
    @State var loggedIn = false
    @State var loginFormShowing = false
    @State var createFormShowing = false
    
    
    var body: some View {
        
        if !loggedIn {
            
            VStack {
                
                //Sign in button
                Button {
                    //Show Login Form
                    loginFormShowing = true
                } label: {
                    Text("Sign In")
                }
                .sheet(isPresented: $loginFormShowing, onDismiss: checkLogin) {
                    LoginForm(formShowing: $loginFormShowing)
                }
                
                //Create account button
                Button {
                    createFormShowing = true
                } label: {
                    Text("Create Account")
                }
                .sheet(isPresented: $createFormShowing, onDismiss: checkLogin) {
                    CreateAccountForm(formShowing: $createFormShowing)
                }

            }
            .onAppear {
                checkLogin()
            }
        }
        else {
            //Show logged in View
            HomePage(loggedIn: $loggedIn)
        }
    }
    
    func checkLogin() {
        loggedIn = Auth.auth().currentUser == nil ? false : true
    }
}

#Preview {
    LaunchView()
}
