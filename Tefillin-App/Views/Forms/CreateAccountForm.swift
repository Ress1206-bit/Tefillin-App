//
//  CreateAccountForm.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAccountForm: View {
    
    @Binding var formShowing: Bool
    
    @State private var showAlert: Bool = false
    
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    
    @State private var isSecured: Bool = true
    
    
    var body: some View {
        Form {
            Section {
                TextField("Full Name", text: $name)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .textCase(.lowercase)
                ZStack(alignment: .trailing) {
                    if isSecured {
                        SecureField("Password", text: $password)
                            .padding(.trailing, 32)
                    } else {
                        TextField("Password", text: $password)
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
            
            Button(action: createAccount) {
                HStack {
                    Spacer()
                    Text("Create Account")
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage!), dismissButton: .default(Text("OK")))
        }
    }
    
    func createAccount(){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if error != nil {
                    errorMessage = error?.localizedDescription
                    showAlert = true
                }
                else if let user = result?.user {
                    // Add the user to Firestore
                    let db = Firestore.firestore()
                    
                    db.collection("users").document(user.uid).setData([
                        "username": username,
                        "email":email,
                        "name": name,
                        "profile_picture_url": "",
                        "account_created": Date(),
                        "post_ids": []
                    ], completion: { error in
                        if error == nil {
                            formShowing = false
                        }
                        else {
                            errorMessage = error?.localizedDescription
                            showAlert = true
                        }
                    })
                }
            }
           
        }
    }
}

#Preview {
    CreateAccountForm(formShowing: Binding.constant(true))
}
