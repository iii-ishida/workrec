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
  @EnvironmentObject var apiClient: ApiClient
  @StateObject private var model = ViewModel()

  var body: some View {
    List {
      ForEach(model.taskList) { task in
        HStack {
          Text(task.title)
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
    //    List() {
    //      ForEach(model.taskList) { task in
    //        HStack {
    //          Text(task.title)
    //        }
    //      }
    //    } .task {
    //      model.fetch()
    //    }
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
      print("S: \(self.taskList)")
      try await apiClient.createTask(title: title)
      self.taskList = try await apiClient.taskList(limit: 10, cursor: nil)
      print("TA: \(self.taskList)")
    } catch {
      print("ERR: \(error)")
    }
  }
}

struct TaskListView_Previews: PreviewProvider {
  static var previews: some View {
    TaskListView()
  }
}
