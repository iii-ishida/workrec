//
//  TaskListView.swift
//  Workrec
//
//  Created by ishida on 2023/03/28.
//

import Apollo
import SwiftUI
import WorkrecGraphql

struct TaskListView: View {
  @StateObject private var model = ViewModel()
  private let apiClient: ApiClient

  init(apiClient: ApiClient) {
    self.apiClient = apiClient
  }

  var body: some View {
    List {
      ForEach(model.taskList) { task in
        HStack {
          TaskRow(task: task) {
            Task {
              await model.toggleWorkOnTask(apiClient: apiClient, task: task)
            }
          }
        }
      }
      TextField("新規タスク", text: $model.title).onSubmit {
        Task {
          await model.addTask(apiClient: apiClient)
        }
      }
    }.task {
      await model.fetch(apiClient: apiClient)
    }
  }
}

private class ViewModel: ObservableObject {
  @Published var taskList: [TaskListItem] = []
  @Published var title = ""

  @MainActor func fetch(apiClient: ApiClient) async {
    self.taskList = try! await apiClient.taskList(limit: 10, cursor: nil)
  }

  @MainActor func addTask(apiClient: ApiClient) async {
    do {
      try await apiClient.createTask(title: title)
      self.taskList = try await apiClient.taskList(limit: 10, cursor: nil, ignoreCache: true)
    } catch {
      print("ERR: \(error)")
    }
  }

  @MainActor func toggleWorkOnTask(apiClient: ApiClient, task: TaskListItem) async {
    let f = task.state == .inProgress ? apiClient.stopWorkOnTask : apiClient.startWorkOnTask
    do {
      try await f(task.id, Date.now)
      self.taskList = try await apiClient.taskList(limit: 10, cursor: nil, ignoreCache: true)
    } catch {
      print("ERR: \(error)")
    }
  }

  @MainActor func stopWorkOnTask(apiClient: ApiClient, taskId: String) async {
    do {
      try await apiClient.stopWorkOnTask(id: taskId, timestamp: Date.now)
      self.taskList = try await apiClient.taskList(limit: 10, cursor: nil, ignoreCache: true)
    } catch {
      print("ERR: \(error)")
    }
  }
}

struct TaskListView_Previews: PreviewProvider {
  static var previews: some View {
    return TaskListView(apiClient: MockApiClient())
  }
}
