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

  static addTask(title) {
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

  static startTask(id, time) {
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

  static pauseTask(id, time) {
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

  static resumeTask(id, time) {
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

  static finishTask(id, time) {
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

  static unfinishTask(id, time) {
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

  static deleteTask(id) {
    return client.mutate({
      mutation: gql`
        mutation($id: ID!) {
          deleteTask(id: $id)
        }`,
      variables: {id}
    })
  }

  static taskListToObject(tasks) {
    return {
      tasks: tasks.edges.map(edge => edge.node),
      endCursor: tasks.pageInfo.endCursor
    }
  }
}
