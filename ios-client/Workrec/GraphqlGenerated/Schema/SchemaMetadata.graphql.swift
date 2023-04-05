// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public protocol WorkrecSchema_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == WorkrecSchema.SchemaMetadata {}

public protocol WorkrecSchema_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == WorkrecSchema.SchemaMetadata {}

public protocol WorkrecSchema_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == WorkrecSchema.SchemaMetadata {}

public protocol WorkrecSchema_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == WorkrecSchema.SchemaMetadata {}

extension WorkrecSchema {
  public typealias ID = String

  public typealias SelectionSet = WorkrecSchema_SelectionSet

  public typealias InlineFragment = WorkrecSchema_InlineFragment

  public typealias MutableSelectionSet = WorkrecSchema_MutableSelectionSet

  public typealias MutableInlineFragment = WorkrecSchema_MutableInlineFragment

  public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    public static func objectType(forTypename typename: String) -> Object? {
      switch typename {
      case "Query": return WorkrecSchema.Objects.Query
      case "TasksConnection": return WorkrecSchema.Objects.TasksConnection
      case "TaskEdge": return WorkrecSchema.Objects.TaskEdge
      case "TaskNode": return WorkrecSchema.Objects.TaskNode
      case "PageInfo": return WorkrecSchema.Objects.PageInfo
      case "Mutation": return WorkrecSchema.Objects.Mutation
      default: return nil
      }
    }
  }

  public enum Objects {}
  public enum Interfaces {}
  public enum Unions {}

}
