// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == WorkrecGraphql.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == WorkrecGraphql.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == WorkrecGraphql.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == WorkrecGraphql.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return WorkrecGraphql.Objects.Query
    case "TasksConnection": return WorkrecGraphql.Objects.TasksConnection
    case "TaskEdge": return WorkrecGraphql.Objects.TaskEdge
    case "TaskNode": return WorkrecGraphql.Objects.TaskNode
    case "PageInfo": return WorkrecGraphql.Objects.PageInfo
    case "Mutation": return WorkrecGraphql.Objects.Mutation
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
