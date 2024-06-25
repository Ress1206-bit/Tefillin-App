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
    var groupIds: [String]
}

struct User: Identifiable {
    var id: String?
    var username: String
    var name: String
    var email: String
    var profilePictureUrl: String
    var accountCreated: Date
    var postIds: [String]
}

struct Group: Identifiable, Hashable {
    var id: String?
    var name: String
    var members: [String]
    var postIds: [String]
    var imageReference: String
    var groupCreated: Date

}

