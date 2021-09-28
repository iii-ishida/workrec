import {
  ApolloClient,
  ApolloLink,
  InMemoryCache,
  HttpLink,
  gql,
  concat,
} from '@apollo/client'

export function newApolloClient(idToken: string): ApolloClient<any> {
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

  return new ApolloClient({
    cache: new InMemoryCache(),
    link,
  })
}

export const GET_TASK_LIST = gql`
  query {
    tasks {
      edges {
        node {
          id
          title
          state
          currentWork {
            startTime
            endTime
          }
          workingTime
          startedAt
          createdAt
          updatedAt
        }
      }
      pageInfo {
        endCursor
      }
    }
  }
`

export const ADD_TASK = gql`
  mutation($title: String!) {
    createTask(title: $title) {
      id
      title
      state
      currentWork {
        startTime
        endTime
      }
      workingTime
      startedAt
      createdAt
      updatedAt
    }
  }
`

export const START_TASK = gql`
  mutation($id: ID!, $time: DateTime!) {
    startTask(id: $id, time: $time) {
      id
      title
      state
      currentWork {
        startTime
        endTime
      }
      workingTime
      startedAt
      createdAt
      updatedAt
    }
  }
`

export const PAUSE_TASK = gql`
  mutation($id: ID!, $time: DateTime!) {
    pauseTask(id: $id, time: $time) {
      id
      title
      state
      currentWork {
        startTime
        endTime
      }
      workingTime
      startedAt
      createdAt
      updatedAt
    }
  }
`

export const RESUME_TASK = gql`
  mutation($id: ID!, $time: DateTime!) {
    resumeTask(id: $id, time: $time) {
      id
      title
      state
      currentWork {
        startTime
        endTime
      }
      workingTime
      startedAt
      createdAt
      updatedAt
    }
  }
`

export const FINISH_TASK = gql`
  mutation($id: ID!, $time: DateTime!) {
    finishTask(id: $id, time: $time) {
      id
      title
      state
      currentWork {
        startTime
        endTime
      }
      workingTime
      startedAt
      createdAt
      updatedAt
    }
  }
`

export const UNFINISH_TASK = gql`
  mutation($id: ID!, $time: DateTime!) {
    unfinishTask(id: $id, time: $time) {
      id
      title
      state
      currentWork {
        startTime
        endTime
      }
      workingTime
      startedAt
      createdAt
      updatedAt
    }
  }
`

export const DELETE_TASK = gql`
  mutation($id: ID!) {
    deleteTask(id: $id)
  }
`
