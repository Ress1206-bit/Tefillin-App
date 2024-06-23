//
//  LoginForm.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseAuth

struct LoginForm: View {
    
    @Binding var formShowing: Bool
    
    @State private var showAlert: Bool = false
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isSecured: Bool = true
    
    
    var body: some View {
        Form {
            Section {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                ZStack(alignment: .trailing) {
                    if isSecured {
                        SecureField("Password", text: $password)
                            .textInputAutocapitalization(.never)
                            .padding(.trailing, 32)
                    } else {
                        TextField("Password", text: $password)
                            .textInputAutocapitalization(.never)
                            .padding(.trailing, 32)
                    }
                    
                    Button(action: {
                        isSecured.toggle()
                    }) {
                        Image(systemName: self.isSecured ? "eye.slash" : "eye")
                            .accentColor(.black)
                    }
                }
            }
            
            Button {
                signIn()
            } label: {
                HStack {
                    Spacer()
                    Text("Sign in")
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage!), dismissButton: .default(Text("OK")))
        }
    }
    
    func signIn(){
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil {
               formShowing = false
            }
            else {
                errorMessage = error?.localizedDescription
                showAlert = true
            }
        }
    }
}

#Preview {
    LoginForm(formShowing: Binding.constant(true))
}
