//
//  CreateNewMessageView.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 26.01.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewChatView: View {
    
    let didSelectNewUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = NewChatViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color(.label), lineWidth: 1))
                            
                            Text(user.username)
                                .foregroundColor(Color(.label))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Message")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
        }
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        AllChatsView()
    }
}
