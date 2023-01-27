//
//  CreateNewMessageViewModel.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 27.01.2023.
//

import Foundation

class NewChatViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    let user = try? snapshot.data(as: ChatUser.self)
                    if user?.uid != FirebaseManager.shared.auth.currentUser?.uid {
                        self.users.append(user!)
                    }
                })
            }
    }
}
