//
//  AuthView.swift
//  Habood
//
//  Created by yunlong chen on 2025/10/17.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Habood")
                .font(.largeTitle)
                .bold()

            Button("Sign in with Google") {
                viewModel.signInWithGoogle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
