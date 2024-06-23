//
//  Tefillin_AppApp.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import Firebase

@main
struct Tefillin_App: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
        }
    }
}
