//
//  ChatLogView.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 26.01.2023.
//

import SwiftUI

struct ChatView: View {
        
    @ObservedObject var vm: ChatViewModel
    
    var body: some View {
        ZStack {
            messagesView
        }
        .navigationTitle(vm.chatUser?.username ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    HStack { Spacer() }
                        .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$shouldScroll) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color("background"))
        .safeAreaInset(edge: .bottom) {
            chatBottomBar
                .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 20) {
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .padding(.leading, 5)
                    .opacity(vm.chatText.isEmpty ? 0.1 : 1)
                RoundedRectangle(cornerRadius: 8).stroke(Color(.secondaryLabel), lineWidth: 0.5)
            }
            .frame(height: 40)
            
            Button {
                vm.handleSend()
                vm.shouldScroll = true
            } label: {
                Image("message")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
            }
//            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Message")
                .foregroundColor(Color(.secondaryLabel))
                .font(.custom(regularFont, size: 18))
                .padding(.leading, 10)
            Spacer()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        AllChatsView()
//            .preferredColorScheme(.dark)
    }
}
