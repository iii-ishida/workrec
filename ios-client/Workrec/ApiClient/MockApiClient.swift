//
//  MockApiClient.swift
//  Workrec
//
//  Created by ishida on 2023/04/10.
//

import Foundation

class MockApiClient: ApiClient {
  override init() {

  }
  override func taskList(limit: Int, cursor: String?, ignoreCache: Bool = false) async throws -> [TaskListItem] {
    (0..<10).map {
      TaskListItem(id: UUID().uuidString, title: "some task \($0 + 1)", state: $0 == 0 ? .inProgress : .notStarted, totalWorkingTime: 0, lastStartTime: Date(timeIntervalSinceNow: -3600))
    }
  }
}
