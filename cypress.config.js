import { defineConfig } from 'cypress'
import { signInWithEmail, startTask, stopTask } from './cypress/helper'

export default defineConfig({
  e2e: {
    setupNodeEvents(on, config) {
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
          const idToken = await signInWithEmail(config, email)

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
          const requests = [...Array(count)].map(async (_, i) => {
            return await fetch(url, {
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
          return startTask(config, arg)
        },
        async toggleTask({ idToken, taskId, timestamp, count }) {
          const date = new Date(timestamp)

          for (let i = 0; i < count; i++) {
            await startTask(config, {
              idToken,
              taskId,
              timestamp: new Date(date.getTime() + i * 2 * 1000 * 60),
            })

            await stopTask(config, {
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
})
