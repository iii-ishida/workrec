//
//  TaskRow.swift
//  Workrec
//
//  Created by ishida on 2023/04/10.
//

import SwiftUI

struct TaskRow: View {
  let task: TaskListItem
  let action: () -> Void

  let dates = [Date(timeIntervalSinceNow: 0)]

  var body: some View {
    TimelineView(.periodic(from: .now, by: task.state == .inProgress ? 60 : 0)) { _ in
      HStack {
        VStack(alignment: .leading) {
          Text(task.title)
          Text(timeText(seconds: task.totalWorkingTimeInCurrent))
            .font(.caption)
        }
        Spacer()
        ToggleButton(isPlay: task.state == .inProgress, action: action)
      }
    }
  }

  private func timeText(seconds: Int) -> String {
    let hours = seconds / 60 / 60
    let minutes = (seconds - (hours * 60 * 60)) / 60

    var text = ""
    if hours != 0 {
      text += String(format: "%02d時間", hours)
    }
    text += String(format: "%02d分", minutes)

    return text
  }
}

struct ToggleButton: View {
  let isPlay: Bool
  let action: () -> Void
  var body: some View {
    Button(action: action) {
      Image(systemName: isPlay ? "stop" : "play")
    }
  }
}

struct TaskRow_Previews: PreviewProvider {
  static var previews: some View {
    Group {

      TaskRow(task: TaskListItem(id: "1", title: "some task", state: .notStarted, totalWorkingTime: 0, lastStartTime: Date.now)) {}

      TaskRow(task: TaskListItem(id: "1", title: "some task", state: .inProgress, totalWorkingTime: 3600, lastStartTime: Date.now)) {}

    }.previewLayout(.fixed(width: 300, height: 70))
  }
}
