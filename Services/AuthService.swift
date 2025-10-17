//
//  AuthViewModel.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//
//  Updated by Yunlong Chen on 17/10/2025
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit
import WidgetKit

/// A service responsible for managing user authentication using **Google Sign-In** and **Firebase**.
///
/// The `AuthService` handles:
/// - Signing in users with Google (OAuth2 → Firebase)
/// - Signing out users
/// - Retrieving the currently signed-in user
/// -  Syncing the signed-in user’s UID to the shared App Group for widgets
///
/// This module fulfills the *Authentication feature* requirement for the iPSE project,
/// integrating external login functionality using UIKit and Firebase SDKs.
///
/// - Author: Stephan Karatselios
/// - Contributor: Yunlong Chen (DocC documentation + App Group integration)
protocol AuthServicing {
    /// The currently signed-in user, if available.
    var currentUser: AppUser? { get }
    
    /// Signs in the user with Google and returns the authenticated `AppUser`.
    ///
    /// - Throws: An error if Google Sign-In or Firebase authentication fails.
    /// - Returns: A signed-in `AppUser` object containing user details.
    func signInWithGoogle() async throws -> AppUser
    
    /// Signs out the current user from both Firebase and Google.
    ///
    /// - Throws: An error if sign-out fails.
    func signOut() throws
}

/// Implementation of `AuthServicing` that provides Google Sign-In and Firebase integration.
///
/// The class performs full OAuth2 authentication via `GIDSignIn` and exchanges
/// Google tokens for Firebase credentials. It supports async/await flow
/// and UIKit integration via the app’s root `UIViewController`.
final class AuthService: AuthServicing {
    private let auth = FirebaseManager.shared.auth
    
    // MARK: - Current User
    
    /// Returns the currently signed-in user as an `AppUser` model.
    ///
    /// - Returns: The `AppUser` if authenticated, otherwise `nil`.
    var currentUser: AppUser? {
        guard let user = auth.currentUser else { return nil }
        return AppUser.fromFirebaseUser(user)
    }
    
    // MARK: - Google Sign-In
    
    /// Signs in the user using **Google Sign-In v7 API** and links credentials to Firebase Authentication.
    ///
    /// After successful login, the user’s UID is stored in the App Group container
    /// (`group.com.habood.shared`) so that the Widget can access the correct Firestore data.
    ///
    /// - Throws:
    ///   - `AuthError.misconfigured` if configuration or token retrieval fails.
    ///   - Any Firebase or Google SDK errors during authentication.
    ///
    /// - Returns: A signed-in `AppUser` representing the authenticated Firebase user.
    func signInWithGoogle() async throws -> AppUser {
        // Get a presenting view controller for the Google sheet
        guard let presenter = Self.rootViewController else {
            throw AuthError.misconfigured("Unable to find root view controller")
        }
        
        // Google Sign-In (v7 API): uses plist clientID automatically
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
        
        // Extract tokens from the Google user
        let googleUser = signInResult.user
        guard let idToken = googleUser.idToken?.tokenString else {
            throw AuthError.misconfigured("Missing Google ID token")
        }
        let accessToken = googleUser.accessToken.tokenString
        
        // Exchange tokens for Firebase credentials
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await auth.signIn(with: credential)
        let firebaseUser = authResult.user
        
        //  Save UID to App Group for Widget access
        let sharedDefaults = UserDefaults(suiteName: "group.com.habood.shared")
        sharedDefaults?.set(firebaseUser.uid, forKey: "userUID")
        sharedDefaults?.synchronize()
        WidgetCenter.shared.reloadAllTimelines()  //  Ask widgets to refresh
        
        print(" UID saved to App Group: \(firebaseUser.uid)")
        print(" Stored UID in App Group:", sharedDefaults?.string(forKey: "userUID") ?? "nil")
        //  Trigger WidgetKit to refresh
        WidgetCenter.shared.reloadAllTimelines()
        print(" Widget timelines reloaded after sign-in")
        
        return AppUser.fromFirebaseUser(firebaseUser)
    }
    
    // MARK: - Sign Out
    
    /// Signs out the user from both Firebase Authentication and Google Sign-In.
    ///
    /// - Throws: An error if sign-out fails.
    func signOut() throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
        
        //  Clear UID from App Group when signing out
        let sharedDefaults = UserDefaults(suiteName: "group.com.habood.shared")
        sharedDefaults?.removeObject(forKey: "userUID")
        WidgetCenter.shared.reloadAllTimelines()
        
        print(" Cleared UID from App Group after sign-out.")
    }
    
    // MARK: - Helpers
    /// Retrieves the app’s root `UIViewController` safely on the main thread.
    ///
    /// - Returns: The key window’s root view controller, if available.
    private static var rootViewController: UIViewController? {
        var rootVC: UIViewController?
        if Thread.isMainThread {
            rootVC = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        } else {
            DispatchQueue.main.sync {
                rootVC = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow })?
                    .rootViewController
            }
        }
        return rootVC
    }
    // MARK: - Error Handling
    
    /// Authentication-related errors with human-readable descriptions.
    enum AuthError: LocalizedError {
        /// Indicates a misconfiguration (e.g., missing Google Client ID or view controller).
        case misconfigured(String)
        /// Fallback for unknown authentication errors.
        case unknown
        
        /// A human-readable error message.
        var errorDescription: String? {
            switch self {
            case .misconfigured(let msg): return msg
            case .unknown: return "Unknown authentication error."
            }
        }
    }
}
