import ApolloClient from 'apollo-boost'
import gql from 'graphql-tag'
import { Task } from 'src/task'

type TaskListResponse = {
  tasks: Task[]
  endCursor?: string
}

export default class API {
  private client: ApolloClient<any>

  constructor(idToken?: string) {
    this.client = new ApolloClient({
      uri: `${process.env.REACT_APP_API_ORIGIN}/graph`,
      request: (operation): any => {
        return operation.setContext({
          headers: {
            authorization: idToken ? `Bearer ${idToken}` : '',
          },
        })
      },
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
      .then(ret => this.taskListToObject(ret.data.tasks))
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
      tasks: tasks.edges.map(edge => edge.node),
      endCursor: tasks.pageInfo.endCursor,
    }
  }
}
