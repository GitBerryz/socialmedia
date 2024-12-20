//
//  ReusablePostsView.swift
//  SocialMedia
//
//  Created by Kevin Berry on 11/24/24.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct ReusablePostsView: View {
    var basedOnUID: Bool = false
    var uid: String = ""
    @Binding var posts: [Post]
    /// - View Properties
    @State private var isFetching: Bool = true
    /// - Pagination
    @State private var paginationDoc: QueryDocumentSnapshot?
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack{
                if isFetching{
                    ProgressView()
                        .padding(.top,30)
                }else{
                    if posts.isEmpty {
                        Text("No Post's Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top,30)
                    }else{
                        /// - Displaying Post's
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            /// - Scroll to Refresh
            /// - Disabling Refresh for UID based Post's
            guard !basedOnUID else{return}
            isFetching = true
            posts = []
            /// - Resetting Pagination Doc
            paginationDoc = nil
            await fetchPosts()
        }
        .task {
            /// - Fetching for One Time
            guard posts.isEmpty else{return}
            await fetchPosts()
        }
    }
    
    /// - Displaying Fetched Post's
    @ViewBuilder
    func Posts()->some View{
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                /// Updating post in the array
                if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                /// Removing Post from the array
                withAnimation(.easeInOut(duration: 0.25)) {
                    posts.removeAll { $0.id == post.id }
                }
            }
            .onAppear {
                /// - When Last Post Appears, Fetching New Post (If There)
                if post.id == posts.last?.id && paginationDoc != nil {
                    Task {
                        await fetchPosts()
                    }
                }
            }
            Divider()
                .padding(.horizontal, -15)
        }
    }
    
    /// - Fetching Post's
    func fetchPosts()async{
        do{
            var query: Query!
            /// - Implement Pagination
            if let paginationDoc{
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .start(afterDocument: paginationDoc)
                    .limit(to: 20)
            } else {
                query = Firestore.firestore().collection("Posts")
                    .order(by: "publishedDate", descending: true)
                    .limit(to: 20)
            }

            /// - New Query For UID Based Document Fetch
            /// - Simply Filter the Post's Which is not Belongs to this UID
            if basedOnUID{
                query = query.whereField("userUID", isEqualTo: uid)
            }
            
            let docs = try await query.getDocuments()
            let fetchedPosts = docs.documents.compactMap { doc -> Post? in
                try? doc.data(as: Post.self)
            }
            await MainActor.run(body: {
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
                isFetching = false
            })
        }catch{
            print(error.localizedDescription)
        }
    }
}
    
#Preview {
    ContentView()
}
