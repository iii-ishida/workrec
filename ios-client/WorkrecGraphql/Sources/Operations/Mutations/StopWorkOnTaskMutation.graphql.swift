// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class StopWorkOnTaskMutation: GraphQLMutation {
  public static let operationName: String = "StopWorkOnTask"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation StopWorkOnTask($taskId: String!, $timestamp: DateTime!) {
        stopWorkOnTask(taskId: $taskId, timestamp: $timestamp) {
          __typename
          id
        }
      }
      """#
    ))

  public var taskId: String
  public var timestamp: DateTime

  public init(
    taskId: String,
    timestamp: DateTime
  ) {
    self.taskId = taskId
    self.timestamp = timestamp
  }

  public var __variables: Variables? { [
    "taskId": taskId,
    "timestamp": timestamp
  ] }

  public struct Data: WorkrecGraphql.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("stopWorkOnTask", StopWorkOnTask.self, arguments: [
        "taskId": .variable("taskId"),
        "timestamp": .variable("timestamp")
      ]),
    ] }

    public var stopWorkOnTask: StopWorkOnTask { __data["stopWorkOnTask"] }

    /// StopWorkOnTask
    ///
    /// Parent Type: `TaskNode`
    public struct StopWorkOnTask: WorkrecGraphql.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.TaskNode }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", WorkrecGraphql.ID.self),
      ] }

      public var id: WorkrecGraphql.ID { __data["id"] }
    }
  }
}
