//
//  ContentView.swift
//  SocialMediaApp
//
//  Created by Kevin Berry on 11/23/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("logStatus") var logStatus: Bool = false
    var body: some View {
        // MARK: Redirecting User based on Log Status
        if logStatus{
            Text("Main View")
        }else{
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
