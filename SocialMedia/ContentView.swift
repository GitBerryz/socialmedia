//
//  ContentView.swift
//  SocialMedia
//
//  Created by Kevin Berry on 11/23/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    var body: some View {
        // MARK: Redirecting User based on Log Status
        if logStatus{
            MainView()
        }else{
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
