import {
  ApolloClient,
  ApolloLink,
  InMemoryCache,
  HttpLink,
  gql,
  concat,
} from '@apollo/client'
import { Task } from '../task'

type TaskListResponse = {
  tasks: Task[]
  endCursor?: string
}

export class API {
  private client: ApolloClient<any>

  constructor(idToken?: string) {
    const httpLink = new HttpLink({
      uri: `${process.env.REACT_APP_API_ORIGIN}/graph`,
    })

    const authMiddleware = new ApolloLink((operation, forward) => {
      operation.setContext({
        headers: {
          authorization: idToken ? `Bearer ${idToken}` : '',
        },
      })

      return forward(operation)
    })

    const link = concat(authMiddleware, httpLink)

    this.client = new ApolloClient({
      cache: new InMemoryCache(),
      link,
    })
  }

  getTaskList(): Promise<TaskListResponse> {
    return this.client
      .query({
        query: gql`
          query {
            tasks {
              edges {
                node {
                  id
                  title
                  state
                  baseWorkingTime
                  startedAt
                  pausedAt
                  createdAt
                  updatedAt
                }
              }
              pageInfo {
                endCursor
              }
            }
          }
        `,
        fetchPolicy: 'network-only',
      })
      .then((ret) => this.taskListToObject(ret.data.tasks))
  }

  addTask(title: string): Promise<any> {
    return this.client.mutate({
      mutation: gql`
        mutation($title: String!) {
          createTask(title: $title) {
            id
            title
            state
            baseWorkingTime
            startedAt
            pausedAt
            createdAt
            updatedAt
          }
        }
      `,
      variables: { title },
    })
  }

  startTask(id: string, time: Date): Promise<any> {
    return this.client.mutate({
      mutation: gql`
        mutation($id: ID!, $time: DateTime!) {
          startTask(id: $id, time: $time) {
            id
            title
            state
            baseWorkingTime
            startedAt
            pausedAt
            createdAt
            updatedAt
          }
        }
      `,
      variables: { id, time },
    })
  }

  pauseTask(id: string, time: Date): Promise<any> {
    return this.client.mutate({
      mutation: gql`
        mutation($id: ID!, $time: DateTime!) {
          pauseTask(id: $id, time: $time) {
            id
            title
            state
            baseWorkingTime
            startedAt
            pausedAt
            createdAt
            updatedAt
          }
        }
      `,
      variables: { id, time },
    })
  }

  resumeTask(id: string, time: Date): Promise<any> {
    return this.client.mutate({
      mutation: gql`
        mutation($id: ID!, $time: DateTime!) {
          resumeTask(id: $id, time: $time) {
            id
            title
            state
            baseWorkingTime
            startedAt
            pausedAt
            createdAt
            updatedAt
          }
        }
      `,
      variables: { id, time },
    })
  }

  finishTask(id: string, time: Date): Promise<any> {
    return this.client.mutate({
      mutation: gql`
        mutation($id: ID!, $time: DateTime!) {
          finishTask(id: $id, time: $time) {
            id
            title
            state
            baseWorkingTime
            startedAt
            pausedAt
            createdAt
            updatedAt
          }
        }
      `,
      variables: { id, time },
    })
  }

  unfinishTask(id: string, time: Date): Promise<any> {
    return this.client.mutate({
      mutation: gql`
        mutation($id: ID!, $time: DateTime!) {
          unfinishTask(id: $id, time: $time) {
            id
            title
            state
            baseWorkingTime
            startedAt
            pausedAt
            createdAt
            updatedAt
          }
        }
      `,
      variables: { id, time },
    })
  }

  deleteTask(id: string): Promise<any> {
    return this.client.mutate({
      mutation: gql`
        mutation($id: ID!) {
          deleteTask(id: $id)
        }
      `,
      variables: { id },
    })
  }

  private taskListToObject(tasks): TaskListResponse {
    return {
      tasks: tasks.edges.map((edge) => edge.node),
      endCursor: tasks.pageInfo.endCursor,
    }
  }
}
