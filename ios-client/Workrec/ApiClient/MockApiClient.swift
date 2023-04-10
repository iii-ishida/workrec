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
  override func taskList(limit: Int, cursor: String?) async throws -> [TaskListItem] {
    return [
      TaskListItem(id: "1", title: "some task", state: .notStarted)
    ]
  }
}
