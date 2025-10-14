//
//  SignInView.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var auth = AuthViewModel()
    
    var body: some View {
        Group {
            if let user = auth.user {
                ContentView(user: user, onSignOut: { auth.signOut() })
            } else {
                LoginView(
                    isLoading: auth.isLoading,
                    errorMessage: auth.errorMessage,
                    onSignIn: { auth.signInWithGoogle() }
                )
            }
        }
    }
}

#Preview {
    SignInView()
}
