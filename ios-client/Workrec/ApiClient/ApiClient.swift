//
//  ApiClient.swift
//  Workrec
//
//  Created by ishida on 2023/03/29.
//

import Apollo
import Combine
import FirebaseAuth
import Foundation
import WorkrecGraphql

struct ApiError: Error {
  let message: String
}

enum TaskState: String {
  case notStarted = "not_started"
  case inProgress = "in_progress"
  case paused = "paused"
  case completed
}

struct TaskListItem: Identifiable {
  let id: String
  let title: String
  let state: TaskState
  let totalWorkingTime: Int
  let lastStartTime: Date

  var totalWorkingTimeInCurrent: Int {
    if state == .inProgress {
      return totalWorkingTime + Int((Date.now.timeIntervalSince(lastStartTime)))
    }
    return totalWorkingTime
  }
}

class ApiClient: ObservableObject {
  private var apolloClient: ApolloClient! = nil

  @Published var authToken: String = ""

  init() {
    let cache = InMemoryNormalizedCache()
    let store = ApolloStore(cache: cache)

    let client = URLSessionClient()
    let provider = NetworkInterceptorProvider(client: client, store: store, provideAuthToken: { self.authToken })
    let url = URL(string: "http://localhost:8080/graphql")!

    let requestChainTransport = RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: url
    )

    self.apolloClient = ApolloClient(networkTransport: requestChainTransport, store: store)
  }

  func taskList(limit: Int, cursor: String?, ignoreCache: Bool = false) async throws -> [TaskListItem] {
    try await withCheckedThrowingContinuation { con in
      apolloClient.fetch(
        query: WorkrecGraphql.TaskListQuery(limit: limit, cursor: nil),
        cachePolicy: ignoreCache ? .fetchIgnoringCacheData : .returnCacheDataElseFetch
      ) { result in
        self.resume(result: result, continuation: con) {
          $0.tasks.edges.map {
            TaskListItem(
              id: $0.node.id,
              title: $0.node.title,
              state: TaskState(rawValue: $0.node.state)!,
              totalWorkingTime: $0.node.totalWorkingTime,
              lastStartTime: ISO8601DateFormatter().date(from: $0.node.lastWork.startTime) ?? Date(timeIntervalSince1970: 0)
            )
          }
        }
      }
    }
  }

  func createTask(title: String) async throws {
    try await withCheckedThrowingContinuation { con in
      apolloClient.perform(mutation: WorkrecGraphql.CreateTaskMutation(title: title)) { result in
        self.resume(result: result, continuation: con) { _ in }
      }
    }
  }

  func startWorkOnTask(id: String, timestamp: Date) async throws {
    try await withCheckedThrowingContinuation { con in
      apolloClient.perform(mutation: WorkrecGraphql.StartWorkOnTaskMutation(taskId: id, timestamp: timestamp.ISO8601Format())) { result in
        self.resume(result: result, continuation: con) { _ in }
      }
    }
  }

  func stopWorkOnTask(id: String, timestamp: Date) async throws {
    try await withCheckedThrowingContinuation { con in
      apolloClient.perform(mutation: WorkrecGraphql.StopWorkOnTaskMutation(taskId: id, timestamp: timestamp.ISO8601Format())) { result in
        self.resume(result: result, continuation: con) { _ in }
      }
    }
  }

  private func resume<T, R>(result: Result<GraphQLResult<T>, Error>, continuation: CheckedContinuation<R, Error>, convert: (T) -> R) {
    switch result {
    case .success(let response):
      if let errors = response.errors {
        continuation.resume(throwing: ApiError(message: errors[0].errorDescription ?? ""))
        return
      }

      continuation.resume(returning: convert(response.data!))

    case .failure(let error):
      continuation.resume(throwing: error)
    }
  }
}

class UserManagementInterceptor: ApolloInterceptor {
  let provideAuthToken: () -> String?

  init(provideAuthToken: @escaping () -> String?) {
    self.provideAuthToken = provideAuthToken
  }

  enum UserError: Error {
    case noUserLoggedIn
  }

  /// Helper function to add the token then move on to the next step
  private func addTokenAndProceed<Operation: GraphQLOperation>(
    _ token: String,
    to request: HTTPRequest<Operation>,
    chain: RequestChain,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    request.addHeader(name: "Authorization", value: "Bearer \(token)")
    chain.proceedAsync(
      request: request,
      response: response,
      completion: completion)
  }

  func interceptAsync<Operation: GraphQLOperation>(
    chain: RequestChain,
    request: HTTPRequest<Operation>,
    response: HTTPResponse<Operation>?,
    completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) {
    guard let token = provideAuthToken() else {
      // In this instance, no user is logged in, so we want to call
      // the error handler, then return to prevent further work
      chain.handleErrorAsync(
        UserError.noUserLoggedIn,
        request: request,
        response: response,
        completion: completion
      )
      return
    }

    self.addTokenAndProceed(
      token,
      to: request,
      chain: chain,
      response: response,
      completion: completion
    )
  }
}

struct NetworkInterceptorProvider: InterceptorProvider {
  let provideAuthToken: () -> String?

  // These properties will remain the same throughout the life of the `InterceptorProvider`, even though they
  // will be handed to different interceptors.
  private let client: URLSessionClient

  private let store: ApolloStore

  init(client: URLSessionClient, store: ApolloStore, provideAuthToken: @escaping () -> String?) {
    self.client = client
    self.store = store
    self.provideAuthToken = provideAuthToken
  }

  func interceptors<Operation: GraphQLOperation>(for operation: Operation) -> [ApolloInterceptor] {
    return [
      MaxRetryInterceptor(),
      CacheReadInterceptor(store: self.store),
      UserManagementInterceptor(provideAuthToken: provideAuthToken),
      NetworkFetchInterceptor(client: self.client),
      ResponseCodeInterceptor(),
      JSONResponseParsingInterceptor(),
      AutomaticPersistedQueryInterceptor(),
      CacheWriteInterceptor(store: self.store),
    ]
  }
}
