//
//  ContentView.swift
//  FirebaseChatApp
//
//  Created by Konstantin Bolgar-Danchenko on 24.01.2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State var loginStatusMessage = ""
    
    @State private var isLoginMode = true
    
    @State private var email = ""
    @State private var password = ""
    @State private var reEnterPassword = ""
    @State var showPassword: Bool = false
    @State var showReEnterPassword: Bool = false
    
    @State var image: UIImage?
    
    @State var shouldShowImagePicker = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            // Login page form
            VStack(spacing: 15) {
                
                if isLoginMode {
                    Image("message")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .padding(.top, 100)
                } else {
                    Button {
                        shouldShowImagePicker.toggle()
                    } label: {
                        VStack {
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .cornerRadius(64)
                            } else {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 64))
                                    .padding()
                                    .foregroundColor(Color("blue"))
                            }
                        }
                        .overlay(RoundedRectangle(cornerRadius: 64)
                            .stroke(Color("blue"), lineWidth: 2)
                            .shadow(color: Color("blue"), radius: 3)
                        )
                    }
                    .padding(.top, 60)
                }
                
                Text(isLoginMode ? "Welcome to Chat" : "Choose Profile Image")
                    .font(.custom(mediumFont, size: 24))
                    .padding(.top, 10)
                
                // Custom text field
                CustomTextField(icon: "envelope.fill", title: "Email", hint: "joe.smith@gmail.com", value: $email, showPassword: $showPassword)
                    .padding(.top, 50)
                
                CustomTextField(icon: "lock.fill", title: "Password", hint: "123456", value: $password, showPassword: $showPassword)
                    .padding(.top, 10)
                
                // Register reenter password
                
                if !isLoginMode {
                    CustomTextField(icon: "lock.fill", title: "Re-Enter Password", hint: "123456", value: $reEnterPassword, showPassword: $showReEnterPassword)
                        .padding(.top, 10)
                }
                
                // Login button
                Button {
                    handleAction()
                } label: {
                    Text(isLoginMode ? "Log In" : "Create Account")
                        .font(.custom(boldFont, size: 20))
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color("blue"))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.07), radius: 5, x: 5, y: 5)
                }
                .padding(.top, 25)
                .padding(.horizontal)
                
                // Log In / Create Account button
                Button {
                    withAnimation {
                        isLoginMode.toggle()
                        loginStatusMessage = ""
                    }
                } label: {
                    Text(isLoginMode ? "Create Account" : "Back to Log In")
                        .font(.custom(mediumFont, size: 16))
                        .foregroundColor(Color("blue"))
                }
                .padding(.top, 8)
                
                Text(loginStatusMessage)
                    .font(.custom(regularFont, size: 18))
                    .foregroundColor(Color.red)
            }
            .padding(30)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("background"))
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    @ViewBuilder
    func CustomTextField(icon: String, title: String, hint: String, value: Binding<String>, showPassword: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(title)
                    .font(.custom(regularFont, size: 18))
                    .foregroundColor(Color(.label))
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(Color("blue"))
            }
            .foregroundColor(Color.black.opacity(0.8))
            
            if title.contains("Password") && !showPassword.wrappedValue {
                SecureField(hint, text: value)
                    .padding(.top, 2)
            } else {
                TextField(hint, text: value)
                    .padding(.top, 2)
            }
            
            Divider()
                .background(Color.black.opacity(0.4))
        }
        // Showing Show Button for password field
        .overlay(
            Group {
                if title.contains("Password") {
                    Button(action: {
                        showPassword.wrappedValue.toggle()
                    }, label: {
                        Text(showPassword.wrappedValue ? "Hide" : "Show")
                            .font(.custom(boldFont, size: 15))
                            .foregroundColor(Color("blue"))
                    })
                    .offset(y: 8)
                }
            }, alignment: .trailing
        )
    }
    
    private func handleAction() {
        
        guard !email.isEmpty, !password.isEmpty else {
            loginStatusMessage = "Email and password cannot be empty"
            return
        }
        
        if isLoginMode {
            loginUser()
        } else {
            
            guard password == reEnterPassword else {
                loginStatusMessage = "Password didn't match"
                return
            }
            
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error {
                print("Failed to login user:", error)
                self.loginStatusMessage = "\(error.localizedDescription)"
                return
            }
            
            self.didCompleteLoginProcess()
        }
    }
    
    private func createNewAccount() {
        
        if self.image == nil {
            self.loginStatusMessage = "You must select a profile image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error {
                print("Failed to create user:", error)
                self.loginStatusMessage = "\(error.localizedDescription)"
                return
            }
            
            persistImageToStorage()
        }
    }
    
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, error in
            
            if let error {
                print(error)
                self.loginStatusMessage = "\(error.localizedDescription)"
                return
            }
            
            ref.downloadURL { url, error in
                if let error {
                    print(error)
                    self.loginStatusMessage = "\(error.localizedDescription)"
                    return
                }
                
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = [FirebaseConstants.email: self.email, FirebaseConstants.uid: uid, FirebaseConstants.profileImageUrl: imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection(FirebaseConstants.users)
            .document(uid).setData(userData) { error in
                if let error {
                    print(error)
                    self.loginStatusMessage = "\(error.localizedDescription)"
                    return
                }
                
                self.didCompleteLoginProcess()
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {
        })
    }
}
