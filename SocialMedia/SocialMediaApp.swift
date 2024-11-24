//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by Kevin Berry on 11/23/24.
//

import SwiftUI
import Firebase

@main
struct SocialMediaApp: App {
    //Add this line to register the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
