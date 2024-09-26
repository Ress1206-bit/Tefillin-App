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
    
    var loggedIn = false
    var agreedToEULA = true //give them the benefit of the doubt haha :)
    
    let db = Firestore.firestore()
    
    var retrievedGroups: [Group] = []
    var currentGroupID = ""
    
    func checkLogin() {
        loggedIn = Auth.auth().currentUser == nil ? false : true
    }
    
    func getUserData() async -> User {
        guard let currentUser = Auth.auth().currentUser else {
            return User(id: "", username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), groupIds: [], postIds: [])
        }
        
        let userID = currentUser.uid
        let userDoc = Firestore.firestore().collection("users").document(userID)
        
        do {
            let snapshot = try await userDoc.getDocument()
            guard let data = snapshot.data() else {
                return User(id: userID, username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), groupIds: [], postIds: [])
            }
            
            let username = data["username"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profilePictureUrl = data["profile_picture_url"] as? String ?? ""
            let accountCreated = (data["accountCreated"] as? Timestamp)?.dateValue() ?? Date()
            let groupIds = data["group_ids"] as? [String] ?? []
            let postIds = data["post_ids"] as? [String] ?? []
            
            return User(id: userID, username: username, name: name, email: email, profilePictureUrl: profilePictureUrl, accountCreated: accountCreated, groupIds: groupIds, postIds: postIds)
            
        } catch {
            print("Error getting document: \(error)")
            return User(id: userID, username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), groupIds: [], postIds: [])
        }
    }
    
    func uploadPostImage(image: UIImage, userID: String, completion: @escaping (String?) -> Void) {

        let storageReference = Storage.storage().reference()

        //turn Image into Data
        let imageData = image.jpegData(compressionQuality: 0.8)

        guard imageData != nil else {
            return
        }

        let path = "images/posts/\(userID)/\(UUID().uuidString).jpg"
        let fileReference = storageReference.child(path)

        fileReference.putData(imageData!, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                completion(path)
            } else {
                completion(nil)
            }
        }

    }
    
    // Upload post image to Firebase Storage
    func uploadGroupImage(image: UIImage, groupID: String, completion: @escaping (String?) -> Void) {

        let storageReference = Storage.storage().reference()

        let imageData = image.jpegData(compressionQuality: 0.8)

        guard imageData != nil else {
            return
        }

        let path = "images/groups/\(groupID)/\(UUID().uuidString).jpg"
        let fileReference = storageReference.child(path)

        fileReference.putData(imageData!, metadata: nil) { metadata, error in
            if error == nil && metadata != nil {
                completion(path)
            } else {
                completion(nil)
            }
        }

    }
    
    func uploadPost(caption: String, image: UIImage, groupIds: [String]) {
        for groupId in groupIds {
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
                        "groups_id": groupId
                    ]) { error in
                        if error != nil {
                            print(error!)
                        } else {
                            self.db.collection("users").document(userID).updateData([
                                "post_ids": FieldValue.arrayUnion([postID])
                            ]) { error in
                                if let error = error {
                                    print(error)
                                }
                            }
                            
                            self.db.collection("groups").document(groupId).updateData([
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
    }
    
    func fetchPosts(amountToGet: Int, amountReceived: Int, groupID: String) async -> [Post] {
        var retrievedPosts: [Post] = []
        var amountSkipped = 0

        guard let currentUser = Auth.auth().currentUser else {
            return []
        }
        
        let blockedUsers = await fetchBlockedUsers()

        do {
            let snapshot = try await self.db.collection("posts")
                .order(by: "time_posted", descending: true)
                .getDocuments()

            for document in snapshot.documents {
                if retrievedPosts.count == amountToGet {
                    break
                }
                
                let data = document.data()
                let retrievedGroupsId = data["groups_id"] as? String ?? ""

                if retrievedGroupsId != groupID {
                    continue
                }
                
                if amountSkipped < amountReceived {
                    amountSkipped += 1
                    continue
                }
                
                let caption = data["caption"] as? String ?? ""
                let userId = data["user_id"] as? String ?? ""
                
                if blockedUsers.contains(userId) {
                    continue
                }
                
                let imageReference = data["image_reference"] as? String ?? ""
                let timePosted = data["time_posted"] as? Date ?? Date()
                let postID = document.documentID
                
                let post = Post(id: postID, userId: userId, caption: caption, imageReference: imageReference, timePosted: timePosted, groupId: currentGroupID)
                
                retrievedPosts.append(post)
            }

        } catch {
            print("Error getting documents: \(error)")
        }
        
        return retrievedPosts
    }

    func fetchUserPosts(userPostIds: [String]) async -> [Post] {
        var posts: [Post] = []

        let blockedUsers = await fetchBlockedUsers()

        do {
            for postId in userPostIds {
                let postDoc = try await db.collection("posts").document(postId).getDocument()
                
                guard let data = postDoc.data(),
                      let userId = data["user_id"] as? String,
                      !blockedUsers.contains(userId),
                      let caption = data["caption"] as? String,
                      let imageReference = data["image_reference"] as? String,
                      let timePosted = (data["time_posted"] as? Timestamp)?.dateValue(),
                      let groupId = data["groups_id"] as? String else {
                    continue
                }
                
                let post = Post(id: postId, userId: userId, caption: caption, imageReference: imageReference, timePosted: timePosted, groupId: groupId)
                posts.append(post)
            }
        } catch {
            print("Error fetching posts: \(error)")
        }

        return posts
    }

    func fetchUserInfo(userID: String) async -> User {
        guard let _ = Auth.auth().currentUser else {
            return User(id: "", username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), groupIds: [], postIds: [])
        }

        let userDoc = Firestore.firestore().collection("users").document(userID)
        
        do {
            let snapshot = try await userDoc.getDocument()
            guard let data = snapshot.data() else {
                return User(id: userID, username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), groupIds: [], postIds: [])
            }
            
            let username = data["username"] as? String ?? ""
            let name = data["name"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profilePictureUrl = data["profile_picture_url"] as? String ?? ""
            let accountCreated = (data["accountCreated"] as? Timestamp)?.dateValue() ?? Date()
            let groupIds = data["group_ids"] as? [String] ?? []
            let postIds = data["post_ids"] as? [String] ?? []
            
            return User(id: userID, username: username, name: name, email: email, profilePictureUrl: profilePictureUrl, accountCreated: accountCreated, groupIds: groupIds, postIds: postIds)
            
        } catch {
            print("Error getting document: \(error)")
            return User(id: userID, username: "", name: "error", email: "", profilePictureUrl: "", accountCreated: Date(), groupIds: [], postIds: [])
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
                
                let groupID = document.documentID
                let members = data["members"] as? [String] ?? []
                let postIds = data["post_ids"] as? [String] ?? []
                let groupCreated = data["time_created"] as? Date ?? Date()
                let imageReference = data["image_reference"] as? String ?? ""
                
                let group = Group(id: groupID, name: name, members: members, postIds: postIds, imageReference: imageReference, groupCreated: groupCreated)
                
                if searchField == "" && retrievedGroups.count < 5 {
                    retrievedGroups.append(group)
                } else {
                    retrievedGroups.append(group)
                }
            }
        } catch {
            print("Error getting documents: \(error)")
        }
    }
    
    func joinGroup(groupID: String) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let userID = currentUser.uid
        
        self.db.collection("groups").document(groupID).updateData([
            "members": FieldValue.arrayUnion([userID])
        ]) { error in
            if let error = error {
                print(error)
            } else {
                self.db.collection("users").document(userID).updateData([
                    "group_ids": FieldValue.arrayUnion([groupID])
                ]) { error in
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
    }
    
    func fetchUserGroups() async -> [Group] {
        guard let currentUser = Auth.auth().currentUser else {
            return []
        }
        
        var userGroups: [Group] = []
        
        do {
            let userSnapshot = try await db.collection("users").document(currentUser.uid).getDocument()
            
            guard let data = userSnapshot.data() else {
                return []
            }
            
            guard let groupIDs = data["group_ids"] as? [String] else {
                return []
            }
            
            for groupID in groupIDs {
                let groupSnapshot = try await db.collection("groups").document(groupID).getDocument()
                
                guard let groupData = groupSnapshot.data() else {
                    return []
                }
                
                let groupName = groupData["groupName"] as? String ?? ""
                let imageReference = groupData["image_reference"] as? String ?? ""
                let members = groupData["members"] as? [String] ?? []
                let postIds = groupData["post_ids"] as? [String] ?? []
                let timeCreated = groupData["time_created"] as? Date ?? Date()
                
                let group = Group(id: groupID, name: groupName, members: members, postIds: postIds, imageReference: imageReference, groupCreated: timeCreated)
                
                userGroups.append(group)
            }
            
        } catch {
            return []
        }

        return userGroups
    }
    

    func blockUser(_ userID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUserID).updateData([
            "blocked_users": FieldValue.arrayUnion([userID])
        ]) { error in
            if let error = error {
                print("Error blocking user: \(error)")
            } else {
                print("User blocked successfully")
            }
        }
    }
    

    func unblockUser(_ userID: String) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(currentUserID).updateData([
            "blocked_users": FieldValue.arrayRemove([userID])
        ]) { error in
            if let error = error {
                print("Error unblocking user: \(error)")
            } else {
                print("User unblocked successfully")
            }
        }
    }

    
    func fetchBlockedUsers() async -> [String] {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return [] }
        let userDoc = try? await db.collection("users").document(currentUserID).getDocument()
        return userDoc?.data()?["blocked_users"] as? [String] ?? []
    }

    func addCommentToPost(text: String, postID: String) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not logged in")
            return
        }
        
        let userID = currentUser.uid
        let commentID = UUID().uuidString
        let commentData: [String: Any] = [
            "post_id": postID,
            "user_id": userID,
            "text": text,
            "time_posted": Timestamp(date: Date())
        ]
        
        db.collection("comments").document(commentID).setData(commentData) { error in
            if let error = error {
                print("Error adding comment: \(error)")
            } else {
                print("Comment added")
            }
        }
    }
    
    func fetchCommentsForPost(postID: String) async throws -> [Comment] {
        let snapshot = try await db.collection("comments")
            .order(by: "time_posted", descending: false)
            .getDocuments()

        var comments: [Comment] = []
        
        for document in snapshot.documents {
            let data = document.data()
            let commentPostID = data["post_id"] as? String ?? ""
            
            if commentPostID != postID {
                continue
            }
            
            let userID = data["user_id"] as? String ?? ""
            let text = data["text"] as? String ?? ""
            let commentID = document.documentID

            let user = await fetchUserInfo(userID: userID)
            
            let comment = Comment(id: commentID, postID: postID, name: user.name, username: user.username, text: text)
            comments.append(comment)
        }
        
        return comments
    }
    
    func reportPost(_ post: Post, reason: String?) {
            let reportID = UUID().uuidString
            let reportData: [String: Any] = [
                "post_id": post.id ?? "",
                "reported_by": Auth.auth().currentUser?.uid ?? "",
                "reason": reason ?? "Not specified",
                "time_reported": Timestamp(date: Date())
            ]

            db.collection("reports").document(reportID).setData(reportData) { error in
                if let error = error {
                    print("Error reporting post: \(error)")
                } else {
                    print("Post reported successfully")
                }
            }
    }
    
    func reportComment(_ comment: Comment, reason: String?) {
        let reportID = UUID().uuidString
        let reportData: [String: Any] = [
            "comment_id": comment.id,
            "post_id": comment.postID,
            "reported_by": Auth.auth().currentUser?.uid ?? "",
            "reason": reason ?? "Not specified",
            "time_reported": Timestamp(date: Date())
        ]

        db.collection("comment_reports").document(reportID).setData(reportData) { error in
            if let error = error {
                print("Error reporting comment: \(error)")
            } else {
                print("Comment reported successfully")
            }
        }
    }
    
    func agreeToEULA() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently logged in.")
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currentUserID)

        userDocRef.updateData(["agreedToEULA": true]) { error in
            if let error = error {
                print(error)
            } else {
                self.agreedToEULA = true
            }
        }
    }
    
    func checkEULA() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: No user is currently logged in.")
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(currentUserID)

        userDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error fetching EULA agreement: \(error)")
                return
            }

            if let document = document, document.exists {
                if let agreedToEULA = document.data()?["agreedToEULA"] as? Bool {
                    self.agreedToEULA = agreedToEULA
                } else {
                    self.agreedToEULA = false
                }
            } else {
                self.agreedToEULA = false
            }
        }
    }

}
