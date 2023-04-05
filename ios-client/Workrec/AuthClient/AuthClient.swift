//
//  AuthClient.swift
//  Workrec
//
//  Created by ishida on 2023/04/02.
//

import Combine
import FirebaseAuth
import Foundation

class AuthState: ObservableObject {
  @Published var isSignedIn: Bool
  @Published var token: String

  init(isSignedIn: Bool, token: String) {
    self.isSignedIn = isSignedIn
    self.token = token
  }
}

struct AuthClient {
  private var cancellableSet: Set<AnyCancellable> = []

  mutating func watchAuthState() -> AnyPublisher<AuthState, Error> {
    let pub = PassthroughSubject<AuthState, Error>()
    Auth.auth().idTokenDidChangePublisher().sink { user in
      guard let user = user else {
        pub.send(AuthState(isSignedIn: false, token: ""))
        return
      }

      user.getIDToken { result, error in
        if let error = error {
          pub.send(completion: .failure(error))
          return
        }

        pub.send(AuthState(isSignedIn: true, token: result ?? ""))
      }
    }.store(in: &cancellableSet)

    return pub.eraseToAnyPublisher()
  }

}
