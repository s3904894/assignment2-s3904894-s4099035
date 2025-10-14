//
//  AuthService.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService: AuthServicing
    
    init(authService: AuthServicing = AuthService()) {
        self.authService = authService
        self.user = authService.currentUser
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let appUser = try await authService.signInWithGoogle()
                self.user = appUser
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
    
    func signOut() {
        do {
            try authService.signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

