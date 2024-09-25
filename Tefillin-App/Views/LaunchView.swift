//
//  LaunchView.swift
//  Tefillin-App
//
//  Created by Adam Ress on 6/23/24.
//

import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    
    @Environment(ContentModel.self) private var contentModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var loginFormShowing = false
    @State private var createFormShowing = false
    @State private var isAnimating = false
    
    var body: some View {
        if contentModel.loggedIn == false {
            VStack {
                Spacer()
                
                Text("Tefillin Wrap Social")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 40)
                    .opacity(isAnimating ? 1 : 0)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .animation(.easeIn(duration: 1).delay(0.5), value: isAnimating)
                
                Button {
                    loginFormShowing = true
                } label: {
                    Text("Sign In")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 10)
                }
                .sheet(isPresented: $loginFormShowing, onDismiss: contentModel.checkLogin) {
                    LoginForm(formShowing: $loginFormShowing)
                }
                .padding(.bottom, 20)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeInOut(duration: 1).delay(1), value: isAnimating)
                
                Button {
                    createFormShowing = true
                } label: {
                    Text("Create Account")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentDarkBlue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 10)
                }
                .sheet(isPresented: $createFormShowing, onDismiss: contentModel.checkLogin) {
                    CreateAccountForm(formShowing: $createFormShowing)
                }
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeInOut(duration: 1).delay(1.2), value: isAnimating)
                
                Spacer()
                
                VStack {

                    Text("Join our community to share and celebrate the mitzvah of tefillin. Connect with others and share your tefillin moments!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Connect with others")
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Share your pictures")
                                .foregroundColor(.primary)
                        }
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Learn and grow together")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)

                    Text("Sponsored by CTeen Atlanta")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                }
                .padding(.top, 20)
                .opacity(isAnimating ? 1 : 0)
                .animation(.easeInOut(duration: 1).delay(1.4), value: isAnimating)
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [
                    colorScheme == .light ? .white : .black,
                    .blue.opacity(0.1)
                ]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .onAppear {
                contentModel.checkLogin()
                withAnimation {
                    isAnimating = true
                }
            }
        }
        else if contentModel.agreedToEULA == false {
            EULAView()
        }
        else {
            HomePage()
        }
    }
}
