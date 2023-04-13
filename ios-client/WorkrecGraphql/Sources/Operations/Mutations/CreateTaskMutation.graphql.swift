// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CreateTaskMutation: GraphQLMutation {
  public static let operationName: String = "CreateTask"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      mutation CreateTask($title: String!) {
        createTask(title: $title) {
          __typename
          id
          state
          title
          totalWorkingTime
          lastWork {
            __typename
            id
            startTime
            endTime
            workingTime
          }
        }
      }
      """#
    ))

  public var title: String

  public init(title: String) {
    self.title = title
  }

  public var __variables: Variables? { ["title": title] }

  public struct Data: WorkrecGraphql.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.Mutation }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("createTask", CreateTask.self, arguments: ["title": .variable("title")]),
    ] }

    public var createTask: CreateTask { __data["createTask"] }

    /// CreateTask
    ///
    /// Parent Type: `TaskNode`
    public struct CreateTask: WorkrecGraphql.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.TaskNode }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("id", WorkrecGraphql.ID.self),
        .field("state", String.self),
        .field("title", String.self),
        .field("totalWorkingTime", Int.self),
        .field("lastWork", LastWork.self),
      ] }

      public var id: WorkrecGraphql.ID { __data["id"] }
      public var state: String { __data["state"] }
      public var title: String { __data["title"] }
      public var totalWorkingTime: Int { __data["totalWorkingTime"] }
      public var lastWork: LastWork { __data["lastWork"] }

      /// CreateTask.LastWork
      ///
      /// Parent Type: `WorkSessionNode`
      public struct LastWork: WorkrecGraphql.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.WorkSessionNode }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("id", WorkrecGraphql.ID.self),
          .field("startTime", WorkrecGraphql.DateTime.self),
          .field("endTime", WorkrecGraphql.DateTime.self),
          .field("workingTime", Int.self),
        ] }

        public var id: WorkrecGraphql.ID { __data["id"] }
        public var startTime: WorkrecGraphql.DateTime { __data["startTime"] }
        public var endTime: WorkrecGraphql.DateTime { __data["endTime"] }
        public var workingTime: Int { __data["workingTime"] }
      }
    }
  }
}
