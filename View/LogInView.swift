//
//  LogInView.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import SwiftUI

struct LoginView: View {
    let isLoading: Bool
    let errorMessage: String?
    let onSignIn: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Mood Logger")
                .font(.largeTitle).bold()
            
            Text("Sign in with your Google account to get started.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Button(action: onSignIn) {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                    Text(isLoading ? "Signing in..." : "Continue with Google")
                        .bold()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue.opacity(0.9))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoading)
            .padding(.horizontal)
            
            if let error = errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

