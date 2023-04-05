// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class TaskListQuery: GraphQLQuery {
  public static let operationName: String = "TaskList"
  public static let document: ApolloAPI.DocumentType = .notPersisted(
    definition: .init(
      #"""
      query TaskList($limit: Int!, $cursor: String) {
        tasks(limit: $limit, cursor: $cursor) {
          __typename
          edges {
            __typename
            node {
              __typename
              id
              state
              title
              totalWorkingTime
            }
          }
          pageInfo {
            __typename
            endCursor
            hasNextPage
          }
        }
      }
      """#
    ))

  public var limit: Int
  public var cursor: GraphQLNullable<String>

  public init(
    limit: Int,
    cursor: GraphQLNullable<String>
  ) {
    self.limit = limit
    self.cursor = cursor
  }

  public var __variables: Variables? { [
    "limit": limit,
    "cursor": cursor
  ] }

  public struct Data: WorkrecGraphql.SelectionSet {
    public let __data: DataDict
    public init(data: DataDict) { __data = data }

    public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("tasks", Tasks.self, arguments: [
        "limit": .variable("limit"),
        "cursor": .variable("cursor")
      ]),
    ] }

    public var tasks: Tasks { __data["tasks"] }

    /// Tasks
    ///
    /// Parent Type: `TasksConnection`
    public struct Tasks: WorkrecGraphql.SelectionSet {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.TasksConnection }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("edges", [Edge].self),
        .field("pageInfo", PageInfo.self),
      ] }

      public var edges: [Edge] { __data["edges"] }
      public var pageInfo: PageInfo { __data["pageInfo"] }

      /// Tasks.Edge
      ///
      /// Parent Type: `TaskEdge`
      public struct Edge: WorkrecGraphql.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.TaskEdge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("node", Node.self),
        ] }

        public var node: Node { __data["node"] }

        /// Tasks.Edge.Node
        ///
        /// Parent Type: `TaskNode`
        public struct Node: WorkrecGraphql.SelectionSet {
          public let __data: DataDict
          public init(data: DataDict) { __data = data }

          public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.TaskNode }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("id", WorkrecGraphql.ID.self),
            .field("state", String.self),
            .field("title", String.self),
            .field("totalWorkingTime", Int.self),
          ] }

          public var id: WorkrecGraphql.ID { __data["id"] }
          public var state: String { __data["state"] }
          public var title: String { __data["title"] }
          public var totalWorkingTime: Int { __data["totalWorkingTime"] }
        }
      }

      /// Tasks.PageInfo
      ///
      /// Parent Type: `PageInfo`
      public struct PageInfo: WorkrecGraphql.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { WorkrecGraphql.Objects.PageInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("endCursor", String.self),
          .field("hasNextPage", Bool.self),
        ] }

        public var endCursor: String { __data["endCursor"] }
        public var hasNextPage: Bool { __data["hasNextPage"] }
      }
    }
  }
}
