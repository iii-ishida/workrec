module.exports = {
  e2e: {
    setupNodeEvents(on, config) {
      const signInWithEmail = async (email) => {
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

      const startTask = async ({ idToken, taskId, timestamp }) => {
        const url = config.env.apiOrigin + '/graphql'

        const query = `
          mutation Mutation($taskId: String!, $timestamp: DateTime!) {
            startWorkOnTask(
              taskId: $taskId,
              timestamp: $timestamp
           ) {
              id
              state
              title
              totalWorkingTime
              lastWork {
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

      const stopTask = async ({ idToken, taskId, timestamp }) => {
        const url = config.env.apiOrigin + '/graphql'

        const query = `
          mutation Mutation($taskId: String!, $timestamp: DateTime!) {
            stopWorkOnTask(
              taskId: $taskId,
              timestamp: $timestamp
            ) {
              id
              state
              title
              totalWorkingTime
              lastWork {
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

      on('task', {
        async createUser(email) {
          const url =
            config.env.firebaseAuthOrigin +
            '/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key'

          return fetch(url, {
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
            .then((res) => res.json())
            .then((res) => res.idToken)
        },

        async createTasks({ email, count }) {
          const idToken = await signInWithEmail(email)

          const query = `
            mutation Mutation($title: String!) {
              createTask(title: $title) {
                id
                title
                totalWorkingTime
                state
              }
            }
          `

          const url = config.env.apiOrigin + '/graphql'
          const requests = [...Array(count)].map((_, i) => {
            return fetch(url, {
              method: 'POST',
              body: JSON.stringify({
                query,
                variables: { title: `task ${i + 1}` },
              }),
              headers: {
                'Content-Type': 'application/json',
                Authorization: 'Bearer ' + idToken,
              },
            })
              .then((res) => res.json())
              .then((res) => res.data.createTask.id)
          })

          return await Promise.all(requests)
        },

        async startTask(arg) {
          return startTask(arg)
        },
        async toggleTask({ idToken, taskId, timestamp, count }) {
          const date = new Date(timestamp)

          for (let i = 0; i < count; i++) {
            await startTask({
              idToken,
              taskId,
              timestamp: new Date(date.getTime() + i * 2 * 1000 * 60),
            })

            await stopTask({
              idToken,
              taskId,
              timestamp: new Date(date.getTime() + (i * 2 + 1) * 1000 * 60),
            })
          }

          return null
        },
      })

      return config
    },
    supportFile: false,
    chromeWebSecurity: false,
  },
  env: {
    apiOrigin: 'http://localhost:8080',
    firebaseAuthOrigin: 'http://localhost:9099',
  },
}
