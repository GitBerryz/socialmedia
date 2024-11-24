//
//  SocialMediaAppApp.swift
//  SocialMediaApp
//
//  Created by Kevin Berry on 11/23/24.
//

import SwiftUI
import Firebase

@main
struct SocialMediaAppApp: App {
    //Add this line to register the app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
