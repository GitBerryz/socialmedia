//
//  ReuseableProfileContent.swift
//  SocialMedia
//
//  Created by Kevin Berry on 11/24/24.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore

struct ReuseableProfileContent: View {
    var user: User
    @State private var drinks: [Drink] = []
    @State private var totalSpent: Double = 0
    @State private var fetchedPosts: [Post] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack {
                // Profile Header Section
                HStack(spacing: 12) {
                    WebImage(url: user.userProfileURL)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(user.username)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                
                // Drink History Summary Section
                if !drinks.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Text("Drink History")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 20) {
                                VStack {
                                    Text("\(drinks.count)")
                                        .font(.title2.bold())
                                    Text("Drinks")
                                        .font(.callout)
                                }
                                
                                VStack {
                                    Text(totalSpent, format: .currency(code: "USD"))
                                        .font(.title2.bold())
                                    Text("Spent")
                                        .font(.callout)
                                }
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.gray.opacity(0.1))
                        }
                        .padding(.horizontal)
                    }
                }
                
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical, 15)
                
                ReusablePostsView(basedOnUID: true, uid: user.userUID, posts: $fetchedPosts)
            }
            .padding(15)
        }
        .task {
            await fetchUserDrinks()
        }
    }
    
    func fetchUserDrinks() async {
        do {
            let snapshot = try await Firestore.firestore().collection("Drinks")
                .whereField("userUID", isEqualTo: user.userUID)
                .order(by: "timestamp", descending: true)
                .limit(to: 50)  // Limit to recent drinks
                .getDocuments()
            
            await MainActor.run {
                drinks = snapshot.documents.compactMap { try? $0.data(as: Drink.self) }
                totalSpent = drinks.reduce(0) { $0 + $1.price }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
