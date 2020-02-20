// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public enum State: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case finished
  case paused
  case resumed
  case started
  case unstarted
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "FINISHED": self = .finished
      case "PAUSED": self = .paused
      case "RESUMED": self = .resumed
      case "STARTED": self = .started
      case "UNSTARTED": self = .unstarted
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .finished: return "FINISHED"
      case .paused: return "PAUSED"
      case .resumed: return "RESUMED"
      case .started: return "STARTED"
      case .unstarted: return "UNSTARTED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: State, rhs: State) -> Bool {
    switch (lhs, rhs) {
      case (.finished, .finished): return true
      case (.paused, .paused): return true
      case (.resumed, .resumed): return true
      case (.started, .started): return true
      case (.unstarted, .unstarted): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [State] {
    return [
      .finished,
      .paused,
      .resumed,
      .started,
      .unstarted,
    ]
  }
}

public final class TaskListQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query TaskList($first: Int!, $cursor: String) {
      tasks(first: $first, cursor: $cursor) {
        __typename
        edges {
          __typename
          node {
            __typename
            id
            title
            state
            actions(first: 5) {
              __typename
              edges {
                __typename
                node {
                  __typename
                  id
                  taskId
                  time
                  type
                }
              }
              pageInfo {
                __typename
                endCursor
                hasNextPage
              }
            }
          }
        }
        pageInfo {
          __typename
          endCursor
          hasNextPage
        }
      }
    }
    """

  public let operationName: String = "TaskList"

  public var first: Int
  public var cursor: String?

  public init(first: Int, cursor: String? = nil) {
    self.first = first
    self.cursor = cursor
  }

  public var variables: GraphQLMap? {
    return ["first": first, "cursor": cursor]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["RootQueryType"]

    public static let selections: [GraphQLSelection] = [
      GraphQLField("tasks", arguments: ["first": GraphQLVariable("first"), "cursor": GraphQLVariable("cursor")], type: .nonNull(.object(Task.selections))),
    ]

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(tasks: Task) {
      self.init(unsafeResultMap: ["__typename": "RootQueryType", "tasks": tasks.resultMap])
    }

    /// Get all tasks
    public var tasks: Task {
      get {
        return Task(unsafeResultMap: resultMap["tasks"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "tasks")
      }
    }

    public struct Task: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["TaskConnection"]

      public static let selections: [GraphQLSelection] = [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("edges", type: .list(.object(Edge.selections))),
        GraphQLField("pageInfo", type: .object(PageInfo.selections)),
      ]

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(edges: [Edge?]? = nil, pageInfo: PageInfo? = nil) {
        self.init(unsafeResultMap: ["__typename": "TaskConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.flatMap { (value: PageInfo) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var edges: [Edge?]? {
        get {
          return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
        }
      }

      public var pageInfo: PageInfo? {
        get {
          return (resultMap["pageInfo"] as? ResultMap).flatMap { PageInfo(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "pageInfo")
        }
      }

      public struct Edge: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["TaskEdge"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("node", type: .nonNull(.object(Node.selections))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(node: Node) {
          self.init(unsafeResultMap: ["__typename": "TaskEdge", "node": node.resultMap])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var node: Node {
          get {
            return Node(unsafeResultMap: resultMap["node"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "node")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Task"]

          public static let selections: [GraphQLSelection] = [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("title", type: .nonNull(.scalar(String.self))),
            GraphQLField("state", type: .nonNull(.scalar(State.self))),
            GraphQLField("actions", arguments: ["first": 5], type: .nonNull(.object(Action.selections))),
          ]

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID, title: String, state: State, actions: Action) {
            self.init(unsafeResultMap: ["__typename": "Task", "id": id, "title": title, "state": state, "actions": actions.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var id: GraphQLID {
            get {
              return resultMap["id"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          public var title: String {
            get {
              return resultMap["title"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "title")
            }
          }

          public var state: State {
            get {
              return resultMap["state"]! as! State
            }
            set {
              resultMap.updateValue(newValue, forKey: "state")
            }
          }

          public var actions: Action {
            get {
              return Action(unsafeResultMap: resultMap["actions"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "actions")
            }
          }

          public struct Action: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["TaskActionConnection"]

            public static let selections: [GraphQLSelection] = [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("edges", type: .list(.object(Edge.selections))),
              GraphQLField("pageInfo", type: .object(PageInfo.selections)),
            ]

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(edges: [Edge?]? = nil, pageInfo: PageInfo? = nil) {
              self.init(unsafeResultMap: ["__typename": "TaskActionConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, "pageInfo": pageInfo.flatMap { (value: PageInfo) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var edges: [Edge?]? {
              get {
                return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
              }
            }

            public var pageInfo: PageInfo? {
              get {
                return (resultMap["pageInfo"] as? ResultMap).flatMap { PageInfo(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "pageInfo")
              }
            }

            public struct Edge: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["TaskActionEdge"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("node", type: .nonNull(.object(Node.selections))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(node: Node) {
                self.init(unsafeResultMap: ["__typename": "TaskActionEdge", "node": node.resultMap])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var node: Node {
                get {
                  return Node(unsafeResultMap: resultMap["node"]! as! ResultMap)
                }
                set {
                  resultMap.updateValue(newValue.resultMap, forKey: "node")
                }
              }

              public struct Node: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["TaskAction"]

                public static let selections: [GraphQLSelection] = [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
                  GraphQLField("taskId", type: .nonNull(.scalar(GraphQLID.self))),
                  GraphQLField("time", type: .nonNull(.scalar(String.self))),
                  GraphQLField("type", type: .nonNull(.scalar(String.self))),
                ]

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(id: GraphQLID, taskId: GraphQLID, time: String, type: String) {
                  self.init(unsafeResultMap: ["__typename": "TaskAction", "id": id, "taskId": taskId, "time": time, "type": type])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var id: GraphQLID {
                  get {
                    return resultMap["id"]! as! GraphQLID
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "id")
                  }
                }

                public var taskId: GraphQLID {
                  get {
                    return resultMap["taskId"]! as! GraphQLID
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "taskId")
                  }
                }

                public var time: String {
                  get {
                    return resultMap["time"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "time")
                  }
                }

                public var type: String {
                  get {
                    return resultMap["type"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "type")
                  }
                }
              }
            }

            public struct PageInfo: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["PageInfo"]

              public static let selections: [GraphQLSelection] = [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("endCursor", type: .scalar(String.self)),
                GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
              ]

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(endCursor: String? = nil, hasNextPage: Bool) {
                self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "hasNextPage": hasNextPage])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var endCursor: String? {
                get {
                  return resultMap["endCursor"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "endCursor")
                }
              }

              public var hasNextPage: Bool {
                get {
                  return resultMap["hasNextPage"]! as! Bool
                }
                set {
                  resultMap.updateValue(newValue, forKey: "hasNextPage")
                }
              }
            }
          }
        }
      }

      public struct PageInfo: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["PageInfo"]

        public static let selections: [GraphQLSelection] = [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("endCursor", type: .scalar(String.self)),
          GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
        ]

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(endCursor: String? = nil, hasNextPage: Bool) {
          self.init(unsafeResultMap: ["__typename": "PageInfo", "endCursor": endCursor, "hasNextPage": hasNextPage])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var endCursor: String? {
          get {
            return resultMap["endCursor"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "endCursor")
          }
        }

        public var hasNextPage: Bool {
          get {
            return resultMap["hasNextPage"]! as! Bool
          }
          set {
            resultMap.updateValue(newValue, forKey: "hasNextPage")
          }
        }
      }
    }
  }
}
