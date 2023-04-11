// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class StartWorkOnTaskMutation: GraphQLMutation {
  public static let operationName: String = "StartWorkOnTask"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation StartWorkOnTask($taskId: String!, $timestamp: DateTime!) {
        startWorkOnTask(taskId: $taskId, timestamp: $timestamp) {
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
      .field("startWorkOnTask", StartWorkOnTask.self, arguments: [
        "taskId": .variable("taskId"),
        "timestamp": .variable("timestamp")
      ]),
    ] }

    public var startWorkOnTask: StartWorkOnTask { __data["startWorkOnTask"] }

    /// StartWorkOnTask
    ///
    /// Parent Type: `TaskNode`
    public struct StartWorkOnTask: WorkrecGraphql.SelectionSet {
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
