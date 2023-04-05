// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

extension WorkrecSchema {
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

    public struct Data: WorkrecSchema.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { WorkrecSchema.Objects.Mutation }
      public static var __selections: [ApolloAPI.Selection] {
        [
          .field("createTask", CreateTask.self, arguments: ["title": .variable("title")])
        ]
      }

      public var createTask: CreateTask { __data["createTask"] }

      /// CreateTask
      ///
      /// Parent Type: `TaskNode`
      public struct CreateTask: WorkrecSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { WorkrecSchema.Objects.TaskNode }
        public static var __selections: [ApolloAPI.Selection] {
          [
            .field("id", WorkrecSchema.ID.self)
          ]
        }

        public var id: WorkrecSchema.ID { __data["id"] }
      }
    }
  }

}
