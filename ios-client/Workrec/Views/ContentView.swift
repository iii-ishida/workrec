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

  var body: some View {
    if model.isSignedIn {
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text("Hello, world!")
      }
      .padding()
    } else {
      VStack {
        SignInView()
      }
    }
  }
}

private class ViewModel: ObservableObject {
  @Published var isSignedIn = false
  private var cancellableSet: Set<AnyCancellable> = []

  init() {
    Auth.auth().authStateDidChangePublisher().map {
      return $0 != nil
    }.assign(to: \.isSignedIn, on: self).store(in: &cancellableSet)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
