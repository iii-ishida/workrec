import ApolloClient from 'apollo-boost'
import gql from 'graphql-tag'
import { getIdToken } from 'src/auth'
import { Task } from 'src/task'

const client = new ApolloClient({
  uri: `${process.env.REACT_APP_API_ORIGIN}/graph`,
  request: (operation): Promise<any> =>  {
    return getIdToken().then(token => {
      operation.setContext({
        headers: {
          authorization: token ? `Bearer ${token}` : ''
        }
      })
    })
  }
})

type TaskListResponse = {
  tasks: Task[];
  endCursor?: string;
}

export default class API {
  static getTaskList(): Promise<TaskListResponse> {
    return client.query({
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
        }`,
      fetchPolicy: 'network-only',
    }).then(ret => this.taskListToObject(ret.data.tasks))
  }

  static addTask(title: string): Promise<any> {
    return client.mutate({
      mutation: gql`
        mutation ($title: String!) {
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
        }`,
      variables: {title}
    })
  }

  static startTask(id: string, time: Date): Promise<any> {
    return client.mutate({
      mutation: gql`
        mutation ($id: ID!, $time: DateTime!) {
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
        }`,
      variables: {id, time}
    })
  }

  static pauseTask(id: string, time: Date): Promise<any> {
    return client.mutate({
      mutation: gql`
        mutation ($id: ID!, $time: DateTime!) {
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
        }`,
      variables: {id, time}
    })
  }

  static resumeTask(id: string, time: Date): Promise<any> {
    return client.mutate({
      mutation: gql`
        mutation ($id: ID!, $time: DateTime!) {
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
        }`,
      variables: {id, time}
    })
  }

  static finishTask(id: string, time: Date): Promise<any> {
    return client.mutate({
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
        }`,
      variables: {id, time}
    })
  }

  static unfinishTask(id: string, time: Date): Promise<any> {
    return client.mutate({
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
        }`,
      variables: {id, time}
    })
  }

  static deleteTask(id: string): Promise<any> {
    return client.mutate({
      mutation: gql`
        mutation($id: ID!) {
          deleteTask(id: $id)
        }`,
      variables: {id}
    })
  }

  private static taskListToObject(tasks): TaskListResponse {
    return {
      tasks: tasks.edges.map(edge => edge.node),
      endCursor: tasks.pageInfo.endCursor
    }
  }
}
