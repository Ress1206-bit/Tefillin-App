//
//  Models.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import Foundation

struct Post: Identifiable, Hashable {
    var id: String?
    var userId: String
    var caption: String
    var imageReference: String
    var timePosted: Date
    var groupId: String
}

struct User: Identifiable {
    var id: String?
    var username: String
    var name: String
    var email: String
    var profilePictureUrl: String
    var accountCreated: Date
    var groupIds: [String]
    var postIds: [String]
}

struct Group: Identifiable, Hashable {
    var id: String
    var name: String
    var members: [String]
    var postIds: [String]
    var imageReference: String
    var groupCreated: Date

}

struct Comment: Identifiable {
    var id: String
    let postID: String
    let name: String
    let username: String
    let text: String
}
