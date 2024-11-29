//
//  ReuseableProfileContent.swift
//  SocialMedia
//
//  Created by Kevin Berry on 11/24/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReuseableProfileContent: View {
    var user: User
    @State private var fetchedPosts: [Post] = []
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                HStack(spacing: 12){
                    WebImage(url: user.userProfileURL)
                        // Image("NullProfile").resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 6){
                    Text(user.username)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(user.userBio)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                    
                    // MARK: Displaying Bio Link, if Given while signing up on sign up
                    if let bioLink = URL(string: user.userBioLink){
                        Link(user.userBioLink, destination: bioLink)
                            .font(.callout)
                            .tint(.blue)
                            .lineLimit(1)
                    }
                }
                .hAlign(.leading)
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
    }
}
