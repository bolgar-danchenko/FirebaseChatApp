//
//  MessageView.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 27.01.2023.
//

import SwiftUI

struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .font(.custom(regularFont, size: 18))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color("blue"))
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .font(.custom(regularFont, size: 18))
                            .foregroundColor(Color(.label))
                    }
                    .padding()
                    .background(Color("messageBubble"))
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
