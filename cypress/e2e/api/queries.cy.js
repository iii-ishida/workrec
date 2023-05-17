describe('Queries Test', () => {
  const url = Cypress.env('apiOrigin') + '/graphql'
  const email = Date.now() + '@example.com'
  const count = 10

  let idToken
  let cursor

  let taskIds

  before(() => {
    cy.task('createUser', email).then((token) => (idToken = token))
    cy.task('createTasks', { email, count }).then((ids) => (taskIds = ids))
  })

  it('Should get tasks', () => {
    const limit = count - 1

    const query = `
      query Query($limit: Int!) {
        tasks(cursor: "", limit: $limit) {
          edges {
            node {
              id
              state
              title
              totalWorkingTime
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    `

    const variables = { limit }

    cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    }).then((res) => {
      expect(res.status).to.eq(200)
      expect(res.body.data.tasks.edges.length).to.eq(limit)
      expect(res.body.data.tasks.pageInfo.endCursor).to.not.be.empty
      expect(res.body.data.tasks.pageInfo.hasNextPage).to.be.true

      cursor = res.body.data.tasks.pageInfo.endCursor
    })
  })

  it('Should get continuation of tasks', () => {
    const query = `
      query Query($cursor: String!) {
        tasks(cursor: $cursor, limit: 1) {
          edges {
            node {
              id
              state
              title
              totalWorkingTime
            }
          }
          pageInfo {
            endCursor
            hasNextPage
          }
        }
      }
    `

    const variables = { cursor }

    cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    }).then((res) => {
      expect(res.status).to.eq(200)
      expect(res.body.data.tasks.edges.length).to.eq(1)
      expect(res.body.data.tasks.pageInfo.endCursor).to.be.empty
      expect(res.body.data.tasks.pageInfo.hasNextPage).to.be.false
    })
  })

  it('Should get related work sessions on a task', () => {
    const taskId = taskIds[0]
    cy.task('toggleTask', {
      idToken,
      taskId,
      timestamp: new Date(2023, 1, 0, 10),
      count: count + 1,
    })

    const query = `
      query Query($taskId: ID!, $workSessionLimit: Int!) {
        task(
          id: $taskId,
        ) {
          id
          workSessions(limit: $workSessionLimit) {
           edges {
             node {
               id
               startTime
               endTime
             }
           }
           pageInfo {
             endCursor
             hasNextPage
          }
        }
      }
    }
    `

    const variables = { taskId, workSessionLimit: count }

    cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    }).then((res) => {
      expect(res.status).to.eq(200)
      expect(res.body.data.task.workSessions.edges.length).to.eq(count)
      expect(res.body.data.task.workSessions.pageInfo.endCursor).to.not.be.empty
      expect(res.body.data.task.workSessions.pageInfo.hasNextPage).to.be.true
    })
  })
})
