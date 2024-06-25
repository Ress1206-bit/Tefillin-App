//
//  ContentModel.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

@Observable
class ContentModel {
    
    // Authentication
    var loggedIn = false
    
    // Reference to Cloud Firestore database
    let db = Firestore.firestore()
    
    
    var retrievedPosts: [Post] = []
    var retrievedGroups: [Group] = []
    
    
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
    
    func uploadPostImage(image: UIImage, userID: String, completion: @escaping (String?) -> Void) {
        
        //reference Storage
        let storageReference = Storage.storage().reference()
        
        //turn Image into Data
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            return
        }
        
        //specify file path and name
        let path = "images/posts/\(userID)/\(UUID().uuidString).jpg"
        let fileReference = storageReference.child(path)

        // upload data
        fileReference.putData(imageData!, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                // Confirm Path
                completion(path)
            } else {
                // Handle the error
                completion(nil)
            }
        }
        
    }
    
    func uploadGroupImage(image: UIImage, groupID: String, completion: @escaping (String?) -> Void) {
        
        //reference Storage
        let storageReference = Storage.storage().reference()
        
        //turn Image into Data
        let imageData = image.jpegData(compressionQuality: 0.8)
        
        guard imageData != nil else {
            return
        }
        
        //specify file path and name
        let path = "images/groups/\(groupID)/\(UUID().uuidString).jpg"
        let fileReference = storageReference.child(path)

        // upload data
        fileReference.putData(imageData!, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                // Confirm Path
                completion(path)
            } else {
                // Handle the error
                completion(nil)
            }
        }
        
    }
    
    func uploadPost(caption: String, image: UIImage, groupIds: [String]) {
        // Check that the user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let userID = currentUser.uid
        let postID = UUID().uuidString
        
        uploadPostImage(image: image, userID: userID) { path in
            if let path = path {
                self.db.collection("posts").document(postID).setData([
                    "user_id": userID,
                    "caption": caption,
                    "image_reference": path,
                    "time_posted": Date(),
                    "groups_ids": []
                ]) { error in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        self.db.collection("users").document(userID).updateData([
                            "post_ids": FieldValue.arrayUnion([postID])
                        ]) { error in
                            if let error = error {
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
        
    func fetchPosts(amount: Int) async {
        // Check that the user is logged in
        guard let _ = Auth.auth().currentUser else {
            return
        }

        let amountOfPostsRetrieved = retrievedPosts.count
        
        do {
            let snapshot = try await self.db.collection("posts")
                .order(by: "time_posted", descending: true)
                .getDocuments()
            
            for (index, document) in snapshot.documents.enumerated() {
                
                
                // Skip the first two documents
                if index < amountOfPostsRetrieved {
                    print("amountOfPostsRetrieved: \(amountOfPostsRetrieved)")
                    print("index: \(index)")
                    continue
                }
                else if index >= amountOfPostsRetrieved + amount {
                    break
                }
                
                let data = document.data()
                let caption = data["caption"] as? String ?? ""
                let userId = data["user_id"] as? String ?? ""
                let imageReference = data["image_reference"] as? String ?? ""
                let groupsIds = data["groups_ids"] as? [String] ?? []
                let timePosted = data["time_posted"] as? Date ?? Date()
                
                let post = Post(userId: userId, caption: caption, imageReference: imageReference, timePosted: timePosted, groupIds: groupsIds)
                
                retrievedPosts.append(post)
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
    func fetchUserInfo(userID: String) async -> User{
        // Check that the user is logged in
        guard let _ = Auth.auth().currentUser else {
            return User(id: "", username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), postIds: [])
        }

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
    
    func fetchImageFromPath(path: String) async -> UIImage? {
        let storageReference = Storage.storage().reference()
        let fileReference = storageReference.child(path)
        
        return await withCheckedContinuation { continuation in
            fileReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error fetching image: \(error)")
                    continuation.resume(returning: nil)
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    continuation.resume(returning: image)
                } else {
                    print("Error: Unable to convert data to UIImage")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func createGroup(groupName: String, image: UIImage) {
        
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let groupID = UUID().uuidString
        
        uploadGroupImage(image: image, groupID: groupID) { path in
            if let path = path {
                self.db.collection("groups").document(groupID).setData([
                    "groupName": groupName,
                    "members": [currentUser.uid],
                    "post_ids": [],
                    "image_reference": path,
                    "time_created": Date()
                ]) { error in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        self.db.collection("users").document(currentUser.uid).updateData(["group_ids": FieldValue.arrayUnion([groupID])]) { error in
                            if error != nil {
                                print(error!)
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    func fetchGroupBySearch(searchField: String) async {
        // Check that the user is logged in
        guard let _ = Auth.auth().currentUser else {
            return
        }
        
        do {
            let snapshot = try await self.db.collection("groups")
                .order(by: "time_created", descending: true)
                .getDocuments()
            
            for document in snapshot.documents {
                
                let data = document.data()
                
                let name = data["groupName"] as? String ?? ""
                

                
                if !name.lowercased().contains(searchField.lowercased()) && searchField != "" {
                    continue
                }
                
                
                let members = data["members"] as? [String] ?? []
                let postIds = data["post_ids"] as? [String] ?? []
                let groupCreated = data["time_created"] as? Date ?? Date()
                let imageReference = data["image_reference"] as? String ?? ""
                
                let group = Group(name: name, members: members, postIds: postIds, imageReference: imageReference, groupCreated: groupCreated)
                
                if searchField == "" && retrievedGroups.count < 5 {
                    retrievedGroups.append(group)
                }
                else {
                    retrievedGroups.append(group)
                }
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
}
