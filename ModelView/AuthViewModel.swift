//
//  AuthViewModel.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//  
//

import Foundation

/// A `ViewModel` class that manages authentication state and actions in the Habood app.
///
/// `AuthViewModel` provides an interface between the user interface (SwiftUI)
/// and the underlying `AuthService`, which handles Google Sign-In and Firebase authentication.
///
/// This class observes changes in user authentication state and provides data binding
/// for login, logout, and error handling in SwiftUI.
///
/// - Author: Stephan Karatselios
/// - Contributor: Yunlong Chen (DocC documentation)
@MainActor
final class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The currently authenticated user.
    ///
    /// This property updates automatically when a sign-in or sign-out event occurs.
    @Published var user: AppUser?
    
    /// A Boolean value that indicates whether a sign-in process is currently running.
    ///
    /// Used to display loading indicators in the user interface.
    @Published var isLoading = false
    
    /// A string message describing any authentication-related error that occurred.
    ///
    /// If `nil`, there is no current error.
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    /// Reference to the authentication service that handles Google Sign-In and Firebase Auth.
    private let authService: AuthServicing
    
    // MARK: - Initializer
    
    /// Creates a new instance of `AuthViewModel` with a given authentication service.
    ///
    /// - Parameter authService: An object conforming to `AuthServicing` (default: `AuthService()`).
    ///
    /// - Example:
    /// ```swift
    /// let viewModel = AuthViewModel(authService: AuthService())
    /// ```
    init(authService: AuthServicing = AuthService()) {
        self.authService = authService
        self.user = authService.currentUser
    }
    
    // MARK: - Sign In with Google
    
    /// Performs Google Sign-In using the provided `AuthService`.
    ///
    /// This function triggers the Google OAuth flow, retrieves Firebase credentials,
    /// and updates the published `user` property when the authentication succeeds.
    ///
    /// - Note:
    ///   This method runs asynchronously using Swift’s `Task` API and must be called
    ///   from the main actor since it updates SwiftUI bindings.
    ///
    /// - Example:
    /// ```swift
    /// viewModel.signInWithGoogle()
    /// ```
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
    
    // MARK: - Sign Out
    
    /// Signs out the currently authenticated user.
    ///
    /// Calls `authService.signOut()` to remove credentials from both Firebase and Google.
    /// Upon completion, the `user` property is set to `nil`.
    ///
    /// - Example:
    /// ```swift
    /// viewModel.signOut()
    /// ```
    func signOut() {
        do {
            try authService.signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
