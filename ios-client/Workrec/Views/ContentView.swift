//
//  ContentView.swift
//  Workrec
//
//  Created by ishida on 2022/10/05.
//

import Combine
import FirebaseAuth
import FirebaseAuthCombineSwift
import SwiftUI

struct ContentView: View {
  @StateObject private var model = ViewModel()
  private var cancellableSet: Set<AnyCancellable> = []

  var body: some View {
    if model.isSignedIn {
      TaskListView().environmentObject(model.apiClient)
    } else {
      SignInView()
    }
  }
}

private class ViewModel: ObservableObject {
  @Published var apiClient = ApiClient()
  @Published var isSignedIn = false

  private var cancellableSet: Set<AnyCancellable> = []

  private var authClient = AuthClient()

  init() {
    Task {
      for try await auth in authClient.watchAuthState().values {
        DispatchQueue.main.async {
          self.isSignedIn = auth.isSignedIn
          self.apiClient.authToken = auth.token
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
