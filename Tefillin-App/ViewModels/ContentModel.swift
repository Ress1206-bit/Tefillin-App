//
//  ContentModel.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import Foundation
import Firebase
import FirebaseAuth

@Observable
class ContentModel {
    
    // Authentication
    var loggedIn = false
    
    
    
    // Reference to Cloud Firestore database
    let db = Firestore.firestore()
    
    
    func checkLogin() {
        loggedIn = Auth.auth().currentUser == nil ? false : true
    }
    
    func getUserData() async -> User {
        // Check that the user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            return User(id: "", username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), postIds: [])
        }
        
        let userID = currentUser.uid
        let userDoc = Firestore.firestore().collection("users").document(userID)
        
        do {
            let snapshot = try await userDoc.getDocument()
            guard let data = snapshot.data() else {
                return User(id: userID, username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), postIds: [])
            }
            
            let username = data["username"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profilePictureUrl = data["profile_picture_url"] as? String ?? ""
            let accountCreated = (data["accountCreated"] as? Timestamp)?.dateValue() ?? Date()
            let postIds = data["post_ids"] as? [String] ?? []
            
            return User(id: userID, username: username, name: name, email: email, profilePictureUrl: profilePictureUrl, accountCreated: accountCreated, postIds: postIds)
            
        } catch {
            print("Error getting document: \(error)")
            return User(id: userID, username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), postIds: [])
        }
    }
    
}
