//
//  SearchUserView.swift
//  SocialMedia
//
//  Created by Kevin Berry on 11/29/24.
//

import SwiftUI
import FirebaseFirestore

struct SearchUserView: View {
    /// - View Properties
    @State private var fetchedUsers: [User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List{
            ForEach(fetchedUsers){ user in
                NavigationLink {
                    ReuseableProfileContent(user: user)
                } label: {
                    Text(user.username)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search, {
            /// - Fetch User From Firebase
            Task{await searchUsers()}
        })
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty{
                fetchedUsers = []
            }
        })
    }
    func searchUsers()async{
        do{
            let documents = try await Firestore.firestore().collection("Users").whereField("username", isGreaterThanOrEqualTo: searchText).whereField("username", isLessThanOrEqualTo: "\(searchText)\u{f8ff}").getDocuments()
            
            let users = try documents.documents.compactMap { doc -> User? in
                try doc.data(as: User.self)
            }
            /// - UI Must be Updated on Main Thread
            await MainActor.run(body: {
                fetchedUsers = users
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}

#Preview {
    SearchUserView()
}