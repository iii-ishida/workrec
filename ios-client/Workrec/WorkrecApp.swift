//
//  WorkrecApp.swift
//  Workrec
//
//  Created by ishida on 2022/10/05.
//

import Firebase
import FirebaseAuth
import SwiftUI

@main
struct WorkrecApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    #if DEBUG
      Auth.auth().useEmulator(withHost: "localhost", port: 9099)
    #endif
    return true
  }
}
