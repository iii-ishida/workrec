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
      ] }

      public var id: WorkrecGraphql.ID { __data["id"] }
    }
  }
}
