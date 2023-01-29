//
//  CreateNewMessageViewModel.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 27.01.2023.
//

import Foundation

class NewChatViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .getDocuments { documentsSnapshot, error in
                if let error {
                    print("Failed to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    do {
                        let user = try snapshot.data(as: ChatUser.self)
                        if user.uid != FirebaseManager.shared.auth.currentUser?.uid {
                            self.users.append(user)
                        }
                    } catch {
                        print(error)
                    }
                })
            }
    }
}
