import { getIdToken } from 'src/auth'

import ApolloClient from 'apollo-boost'
import gql from 'graphql-tag'

const client = new ApolloClient({
  uri: `${process.env.REACT_APP_API_ORIGIN}/graph`,
  request: (operation) => {
    return getIdToken().then(token => {
      operation.setContext({
        headers: {
          authorization: token ? `Bearer ${token}` : ''
        }
      })
    })
  }
})

export default class API {
  static getTaskList() {
    return client.query({
      query: gql`
        query {
          list {
            tasks {
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
        }`,
      fetchPolicy: 'network-only',
    }).then(ret => this.taskListToObject(ret.data.list))
  }

  static addTask(title) {
    return client.mutate({
      mutation: gql`mutation ($title: String!) {
        createTask(title: $title)
      }`,
      variables: {title}
    })
  }

  static startTask(id, time) {
    return client.mutate({
      mutation: gql`mutation ($id: ID!, $time: DateTime!) {
        startTask(id: $id, time: $time)
      }`,
      variables: {id, time}
    })
  }

  static pauseTask(id, time) {
    return client.mutate({
      mutation: gql`
        mutation ($id: ID!, $time: DateTime!) {
          pauseTask(id: $id, time: $time)
        }`,
      variables: {id, time}
    })
  }

  static resumeTask(id, time) {
    return client.mutate({
      mutation: gql`
        mutation ($id: ID!, $time: DateTime!) {
          resumeTask(id: $id, time: $time)
        }`,
      variables: {id, time}
    })
  }

  static finishTask(id, time) {
    return client.mutate({
      mutation: gql`
        mutation($id: ID!, $time: DateTime!) {
          finishTask(id: $id, time: $time)
        }`,
      variables: {id, time}
    })
  }

  static unfinishTask(id, time) {
    return client.mutate({
      mutation: gql`
        mutation($id: ID!, $time: DateTime!) {
          unfinishTask(id: $id, time: $time)
        }`,
      variables: {id, time}
    })
  }

  static deleteTask(id) {
    return client.mutate({
      mutation: gql`
        mutation($id: ID!) {
          deleteTask(id: $id)
        }`,
      variables: {id}
    })
  }

  static taskListToObject(list) {
    return {
      tasks: list.tasks,
      nextPageToken: list.nextPageToken
    }
  }
}
