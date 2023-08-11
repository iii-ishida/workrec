export const signInWithEmail = async (config, email) => {
  const url =
    config.env.firebaseAuthOrigin +
    '/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key'

  return await fetch(url, {
    method: 'POST',
    body: JSON.stringify({
      email,
      password: 'PASSWORD',
      returnSecureToken: true,
    }),
    headers: {
      'Content-Type': 'application/json',
    },
  })
    .then((res) => {
      return res.json()
    })
    .then((res) => {
      return res.idToken
    })
}

export const startTask = async (config, { idToken, taskId, timestamp }) => {
  const url = config.env.apiOrigin + '/graphql'

  const query = `
          mutation Mutation($taskId: ID!, $timestamp: DateTime!) {
            startWorkOnTask(
              taskId: $taskId,
              timestamp: $timestamp
           ) {
              id
              state
              title
              totalWorkingTime
              currentWorkSession {
                id
                startTime
                endTime
                workingTime
              }
            }
          }
        `

  const variables = { taskId, timestamp }

  return await fetch(url, {
    method: 'POST',
    body: JSON.stringify({ query, variables }),
    headers: {
      'Content-Type': 'application/json',
      Authorization: 'Bearer ' + idToken,
    },
  }).then((res) => res.json())
}

export const stopTask = async (config, { idToken, taskId, timestamp }) => {
  const url = config.env.apiOrigin + '/graphql'

  const query = `
          mutation Mutation($taskId: ID!, $timestamp: DateTime!) {
            stopWorkOnTask(
              taskId: $taskId,
              timestamp: $timestamp
            ) {
              id
              state
              title
              totalWorkingTime
              currentWorkSession {
                id
                startTime
                endTime
                workingTime
              }
            }
          }
        `

  const variables = { taskId, timestamp }

  return await fetch(url, {
    method: 'POST',
    body: JSON.stringify({ query, variables }),
    headers: {
      'Content-Type': 'application/json',
      Authorization: 'Bearer ' + idToken,
    },
  }).then((res) => res.json())
}
