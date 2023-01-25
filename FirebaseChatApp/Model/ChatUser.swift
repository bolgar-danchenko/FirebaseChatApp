//
//  ChatUser.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 25.01.2023.
//

import Foundation

struct ChatUser {
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
