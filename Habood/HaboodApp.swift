//
//  HaboodApp.swift
//  Habood
//
//  Created by Stephan Karatselios on 8/10/2025.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      if FirebaseApp.app() == nil {
          FirebaseApp.configure()
      }
      
      if let clientID = FirebaseApp.app()?.options.clientID {
          GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
      } else {
          assertionFailure("Missing FireBase Client ID. Check GoogleService-Info.plit target membership")
      }
    return true
  }
}

func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey : Any] = [:]) ->
                    Bool {
    return GIDSignIn.sharedInstance.handle(url)
}

@main
struct HaboodApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SignInView()
        }
        .modelContainer(for: SettingsItem.self)
    }
}
