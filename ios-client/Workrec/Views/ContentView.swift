//
//  ContentView.swift
//  Workrec
//
//  Created by ishida on 2022/10/05.
//

import Combine
import SwiftUI

struct ContentView: View {
  @StateObject private var model = ViewModel()
  private var cancellableSet: Set<AnyCancellable> = []

  var body: some View {
    if model.isSignedIn {
      TaskListView(apiClient: model.apiClient)
    } else {
      SignInView()
    }
  }
}

@MainActor
private class ViewModel: ObservableObject {
  @Published var apiClient = ApiClient()
  @Published var isSignedIn = false

  private var cancellableSet: Set<AnyCancellable> = []

  private var authClient = AuthClient()

  init() {
    Task {
      for try await auth in authClient.watchAuthState().values {
        self.isSignedIn = auth.isSignedIn
        self.apiClient.authToken = auth.token
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
