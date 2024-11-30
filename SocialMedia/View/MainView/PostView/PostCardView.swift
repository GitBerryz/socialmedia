//
//  PostCardView.swift
//  SocialMedia
//
//  Created by Kevin Berry on 11/24/24.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
import FirebaseFirestore

struct PostCardView: View {
    var post: Post
    /// - Callbacks
    var onUpdate: (Post)->()
    var onDelete: ()->()
    /// - View Properties
    @AppStorage("user_UID") private var userUID: String = ""
    @State private var docListener: ListenerRegistration?
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date: .numeric, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical,8)
                
                /// Post Image If Any
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        WebImage(url: postImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                    }
                    .frame(height:200)
                }
                
                PostInteraction()
                    .allowsHitTesting(true)
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing) {
            if post.userUID == userUID {
                Menu {
                    Button("Delete Post", role: .destructive, action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x: 8)
            }
        }
        .onAppear {
            setupListener()
            print("Post ID: \(post.id ?? "nil"), UserUID: \(post.userUID)")
        }
        .onDisappear {
            removeListener()
        }
    }
    
    private func setupListener() {
        removeListener()
        
        guard let postID = post.id else { return }
        docListener = Firestore.firestore().collection("Posts").document(postID)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot,
                      snapshot.exists,
                      let updatedPost = try? snapshot.data(as: Post.self)
                else {
                    if let error = error {
                        print("Error listening to post updates: \(error.localizedDescription)")
                    }
                    if snapshot?.exists == false {
                        onDelete()
                    }
                    return
                }
                
                onUpdate(updatedPost)
            }
    }
    
    private func removeListener() {
        docListener?.remove()
        docListener = nil
    }
    
    // MARK: Like/Dislike Interaction
    @ViewBuilder
    func PostInteraction()->some View{
        HStack(spacing: 6) {
            Button(action: likePost){
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .contentShape(Rectangle())
                    .frame(minWidth: 44, minHeight: 44)
            }
            
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: dislikePost){
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                    .contentShape(Rectangle())
                    .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.leading,25)
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(.vertical,8)
        .contentShape(Rectangle())
        .zIndex(1)
    }
    
    /// - Liking Post
    func likePost(){
        Task {
            do {
                guard let postID = post.id else { return }
                if post.likedIDs.contains(userUID) {
                    /// Removing User ID from the Array
                    try await Firestore.firestore().collection("Posts").document(postID).updateData([
                        "likedIDs": FieldValue.arrayRemove([userUID])
                    ])
                } else {
                    /// Adding User ID to liked array and removing our ID from Disliked array (if Added in prior)
                    try await Firestore.firestore().collection("Posts").document(postID).updateData([
                        "likedIDs": FieldValue.arrayUnion([userUID]),
                        "dislikedIDs": FieldValue.arrayRemove([userUID])
                    ])
                }
            } catch {
                print("Error updating like status: \(error.localizedDescription)")
            }
        }
    }
    
    /// - Dislike Post
    func dislikePost(){
        Task {
            do {
                guard let postID = post.id else { return }
                if post.dislikedIDs.contains(userUID){
                    /// Removing User ID from the Array
                    try await Firestore.firestore().collection("Posts").document(postID).updateData([
                        "dislikedIDs": FieldValue.arrayRemove([userUID])
                    ])
                } else {
                    /// Adding User ID to disliked array and removing our ID from liked array (if Added in prior)
                    try await Firestore.firestore().collection("Posts").document(postID).updateData([
                        "likedIDs": FieldValue.arrayRemove([userUID]),
                        "dislikedIDs": FieldValue.arrayUnion([userUID])
                    ])
                }
            } catch {
                print("Error updating dislike status: \(error.localizedDescription)")
            }
        }
    }
    /// - Deleting Post
    func deletePost(){
        Task {
            /// Step 1: Delete Image from Firebase Storage if present
            do{
                if post.imageReferenceID != ""{
                    try await Storage.storage().reference().child("post_Images").child(post.imageReferenceID).delete()
                }
                /// Step 2: Delete Firestore Document
                guard let postID = post.id else{return}
                try await Firestore.firestore().collection("Posts").document(postID).delete()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
