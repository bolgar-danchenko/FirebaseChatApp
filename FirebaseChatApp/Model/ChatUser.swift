//
//  ChatUser.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 25.01.2023.
//

import FirebaseFirestoreSwift

struct ChatUser: Codable, Identifiable {
    @DocumentID var id: String?
    let uid, email, profileImageUrl: String
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
}
