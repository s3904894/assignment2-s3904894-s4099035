//
//  AuthService.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//  Documented by Yunlong Chen

import Foundation


/// A `ViewModel` class that manages authentication state and actions in the Habood app.
///
/// `AuthViewModel` provides an interface between the user interface (SwiftUI)
/// and the underlying `AuthService`, which handles Google Sign-In and Firebase authentication.
///
/// This class observes changes in user authentication state and provides data binding
/// for login, logout, and error handling in SwiftUI.
///


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

