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
                                .shadow(color: Color("blue"), radius: 3)
                            
                            Text(user.username)
                                .font(.custom(boldFont, size: 18))
                                .foregroundColor(Color(.label))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .padding(.vertical, 5)
                    }
                    Divider()
                        .background(Color(.secondaryLabel))
                }
                .padding(.horizontal)
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            
                            Text("Back")
                                .font(.custom(regularFont, size: 18))
                        }
                    }
                }
            }
            .background(Color("background"))
        }
    }
}

struct NewChatView_Previews: PreviewProvider {
    static var previews: some View {
        NewChatView(didSelectNewUser: { _ in
            
        })
        .preferredColorScheme(.dark)
    }
}
