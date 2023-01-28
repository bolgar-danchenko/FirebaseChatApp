//
//  MainMessagesView.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 25.01.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct AllChatsView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = AllChatsViewModel()
    
    private var chatLogViewModel = ChatViewModel(chatUser: nil)
    
    var body: some View {
        NavigationStack {
            VStack {
                customNavBar
                messagesView
            }
            .background(Color("background"))
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $shouldNavigateToChatLogView) {
                ChatView(vm: chatLogViewModel)
            }
        }
    }
    
    private var customNavBar: some View {
        
        HStack(spacing: 16) {
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .shadow(color: Color("blue"), radius: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.chatUser?.username ?? "")
                    .font(.custom(boldFont, size: 24))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    
                    Text("online")
                        .font(.custom(regularFont, size: 14))
                        .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("blue"))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    vm.handleSignOut()
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
                self.vm.fetchRecentMessages()
            })
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        
                        self.chatUser = .init(id: uid, uid: uid, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl)
                        self.chatLogViewModel.chatUser = self.chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
                    } label: {
                        HStack(spacing: 16) {
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .shadow(color: Color("blue"), radius: 3)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(recentMessage.username)
                                    .font(.custom(boldFont, size: 18))
                                    .foregroundColor(Color(.label))
                                    .multilineTextAlignment(.leading)
                                Text(recentMessage.text)
                                    .font(.custom(regularFont, size: 16))
                                    .foregroundColor(Color(.darkGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
//                                .font(.system(size: 14, weight: .semibold))
                                .font(.custom(mediumFont, size: 14))
                                .foregroundColor(Color("blue"))
                        }
                        .frame(maxWidth: .infinity, maxHeight: 80)
                        .padding(.vertical, 5)
                    }
                    Divider()
//                        .padding(.vertical, 1)
                }
                .padding(.horizontal)
            }
        }
        .padding(.bottom, 50)
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View {
        Button {
            shouldShowNewMessageScreen.toggle()
        } label: {
            HStack {
                Spacer()
                ZStack {
                    Circle()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("background"))
                        .shadow(color: Color("blue"), radius: 5)
                    
                    Image("message")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                .padding(.trailing, 30)
            }
        }
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen) {
            NewChatView(didSelectNewUser: { user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
                self.chatLogViewModel.chatUser = user
                self.chatLogViewModel.fetchMessages()
            })
        }
    }
    
    @State var chatUser: ChatUser?
}

struct AllChatsView_Previews: PreviewProvider {
    static var previews: some View {
        AllChatsView()
//            .preferredColorScheme(.dark)
    }
}
