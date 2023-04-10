//
//  SignInView.swift
//  Workrec
//
//  Created by ishida on 2023/03/27.
//

import Combine
import SwiftUI

struct SignInView: View {
  @StateObject private var model = ViewModel()

  var body: some View {
    VStack {
      VStack {
        VStack(alignment: .leading) {
          Text("email")
          TextField("", text: $model.email)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .textContentType(.emailAddress)
        }

        Spacer().frame(height: 16)

        VStack(alignment: .leading) {
          Text("password")
          SecureField("", text: $model.password)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .textContentType(.newPassword)
        }

        Text(model.error).foregroundColor(.red).font(.caption)
      }

      Spacer().frame(height: 134)

      Button(action: model.submit) {
        Text(model.mode == .signIn ? "ログイン" : "アカウント作成")
          .frame(maxWidth: .infinity, minHeight: 44.0)
          .foregroundColor(.white)
      }
      .background(Color.blue)
      .cornerRadius(4.0)

      Spacer().frame(height: 32)

      Button(action: model.toggleMode) {
        HStack {
          Spacer()
          Text(model.mode == .signIn ? "アカウントを新規作成する" : "既存のアカウントでログインする")
            .font(.caption)
            .multilineTextAlignment(.trailing)
        }
      }

      Spacer().frame(height: 32)

      Button(action: model.signInAsAnonymus) {
        HStack {
          Spacer()
          Text("スキップ >")
            .font(.caption)
            .multilineTextAlignment(.trailing)
        }
      }

      Spacer()
    }.padding()
  }
}

private class ViewModel: ObservableObject {
  enum Mode {
    case signUp
    case signIn
  }

  private var authClient = AuthClient()

  var email = ""
  var password = ""
  @Published var mode: Mode = .signIn
  @Published var error = ""

  private var cancellableSet: Set<AnyCancellable> = []
  private var isValid: Bool {
    email != "" && password != ""
  }

  func toggleMode() {
    if mode == .signUp {
      mode = .signIn
    } else {
      mode = .signUp
    }
  }

  func submit() {
    guard isValid else { return }

    var future: AnyPublisher<Void, Error>

    if mode == .signUp {
      future = authClient.createUser(withEmail: email, password: password)
    } else {
      future = authClient.signIn(withEmail: email, password: password)
    }

    handleAuthCompletion(result: future)
  }

  func signInAsAnonymus() {
    handleAuthCompletion(result: authClient.signInAnonymously())
  }

  private func handleAuthCompletion(result: AnyPublisher<Void, Error>) {
    result
      .receive(on: RunLoop.main)
      .sink(
        receiveCompletion: { result in
          switch result {
          case .failure(let error):
            self.error = error.localizedDescription
          default:
            self.error = ""
          }
        },
        receiveValue: { _ in }
      ).store(in: &cancellableSet)
  }
}

struct SignInView_Previews: PreviewProvider {
  static var previews: some View {
    SignInView()
  }
}
