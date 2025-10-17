//
//  HaboodApp.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//  Updated by Yunlong Chen on 17/10/2025
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

// MARK: - AppDelegate
/// Handles Firebase and Google Sign-In configuration at app launch.
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //  Initialize Firebase once only
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print(" Firebase configured successfully.")
        }
        
        //  Setup Google Sign-In configuration
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            print(" GoogleSignIn configured with clientID: \(clientID)")
        } else {
            assertionFailure(" Missing Firebase Client ID. Check GoogleService-Info.plist target membership.")
        }
        
        return true
    }
    
    ///  Handles Google Sign-In redirect after user authentication
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Main App
@main
struct HaboodApp: App {
    // Inject AppDelegate lifecycle handler
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if let user = viewModel.user {
                ContentView(
                    user: user,
                    onSignOut: { viewModel.signOut() }
                )
            } else {
                AuthView(viewModel: viewModel)
            }
        }
        //  Model container for SwiftData (iOS 17+)
        .modelContainer(for: MoodEntry.self)
    }
}
