//
//  ChatMessage.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 27.01.2023.
//

import Foundation
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    
//    var id: String { documentId }
    
    @DocumentID var id: String?
    
//    let documentId: String
    let fromId, toId, text: String
    let timestamp: Date
    
//    init(documentId: String, data: [String: Any]) {
//        self.documentId = documentId
//        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
//        self.toId = data[FirebaseConstants.toId] as? String ?? ""
//        self.text = data[FirebaseConstants.text] as? String ?? ""
//    }
}
