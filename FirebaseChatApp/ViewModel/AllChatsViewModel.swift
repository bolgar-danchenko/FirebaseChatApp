//
//  MainMessagesViewModel.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 27.01.2023.
//

import Foundation
import FirebaseFirestore

class AllChatsViewModel: ObservableObject {
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    init() {
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private var firestoreListener: ListenerRegistration?
    
    func fetchRecentMessages() {
        
        firestoreListener?.remove()
        self.recentMessages.removeAll()
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        firestoreListener = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do {
                        let rm = try change.document.data(as: RecentMessage.self)
                        self.recentMessages.insert(rm, at: 0)
                    } catch {
                        print(error)
                    }
                })
            }
    }
    
    func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users).document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                print(error)
                return
            }
            self.chatUser = try? snapshot?.data(as: ChatUser.self)
            FirebaseManager.shared.currentUser = self.chatUser
        }
    }
    
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
}
