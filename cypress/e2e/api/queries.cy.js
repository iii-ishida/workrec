describe('tasks', () => {
  const count = 10

  let idToken
  let taskIds

  beforeEach(() => {
    const email = Date.now() + '@example.com'

    cy.task('createUser', email).then((token) => (idToken = token))
    cy.task('createTasks', { email, count }).then((ids) => (taskIds = ids))
  })

  it('cursor を指定されていない場合は最初から取得', () => {
    const limit = count - 1

    fetchTasks(idToken, limit).then((res) => {
      expect(res.status).to.eq(200)
      expect(res.body.data.tasks.edges.length).to.eq(limit)
      expect(res.body.data.tasks.pageInfo.endCursor).to.not.be.empty
      expect(res.body.data.tasks.pageInfo.hasNextPage).to.be.true
    })
  })

  it('cursor を指定された場合は続きから取得', () => {
    const limit = count - 1

    // 1回目取得
    fetchTasks(idToken, limit).then((res) => {
      expect(res.body.data.tasks.pageInfo.endCursor).to.not.be.empty

      // 続き取得
      const cursor = res.body.data.tasks.pageInfo.endCursor
      fetchTasks(idToken, limit, cursor).then((res) => {
        expect(res.status).to.eq(200)
        expect(res.body.data.tasks.edges.length).to.eq(1)
        expect(res.body.data.tasks.pageInfo.endCursor).to.be.empty
        expect(res.body.data.tasks.pageInfo.hasNextPage).to.be.false
      })
    })
  })
})

describe('workSessions', () => {
  const count = 10

  let idToken
  let taskId

  beforeEach(() => {
    const email = Date.now() + '@example.com'

    cy.task('createUser', email).then((token) => (idToken = token))
    cy.task('createTasks', { email, count: 1 }).then((ids) => {
      taskId = ids[0]
    })
  })

  it('cursor を指定されていない場合は最初から取得', () => {
    cy.task('toggleTask', {
      idToken,
      taskId,
      timestamp: new Date(2023, 1, 0, 10),
      count: count,
    })

    const limit = count - 1

    fetchWorkSessions(idToken, taskId, limit).then((res) => {
      expect(res.status).to.eq(200)
      expect(res.body.data.task.workSessions.edges.length).to.eq(limit)
      expect(res.body.data.task.workSessions.pageInfo.endCursor).to.not.be.empty
      expect(res.body.data.task.workSessions.pageInfo.hasNextPage).to.be.true

      const sorted = [...res.body.data.task.workSessions.edges].sort(
        (a, b) =>
          new Date(a.node.startTime).getTime() -
          new Date(b.node.startTime).getTime()
      )
      expect(res.body.data.task.workSessions.edges).to.have.ordered.members(
        sorted
      )
    })
  })

  it('cursor を指定された場合は続きから取得', () => {
    cy.task('toggleTask', {
      idToken,
      taskId,
      timestamp: new Date(2023, 1, 0, 10),
      count: count,
    })

    const limit = count - 1

    // 1回目取得
    fetchWorkSessions(idToken, taskId, limit).then((res) => {
      expect(res.body.data.task.workSessions.pageInfo.endCursor).to.not.be.empty

      // 続き取得
      const cursor = res.body.data.task.workSessions.pageInfo.endCursor
      fetchWorkSessions(idToken, taskId, limit, cursor).then((res) => {
        expect(res.status).to.eq(200)
        expect(res.body.data.task.workSessions.edges.length).to.eq(1)
        expect(res.body.data.task.workSessions.pageInfo.endCursor).to.be.empty
        expect(res.body.data.task.workSessions.pageInfo.hasNextPage).to.be.false
      })
    })
  })
})

const fetchTasks = (idToken, limit, cursor) => {
  const url = Cypress.env('apiOrigin') + '/graphql'

  const query = `
      query Query($limit: Int!, $cursor: String) {
        tasks(cursor: $cursor, limit: $limit) {
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

  const variables = { limit, cursor }

  return cy.request({
    url,
    method: 'POST',
    body: { query, variables },
    headers: {
      'Content-Type': 'application/json',
      Authorization: 'Bearer ' + idToken,
    },
  })
}

const fetchWorkSessions = (idToken, taskId, limit, cursor) => {
  const url = Cypress.env('apiOrigin') + '/graphql'

  const query = `
      query Query($taskId: ID!, $limit: Int!, $cursor: String) {
        task(
          id: $taskId,
        ) {
          id
          workSessions(limit: $limit, cursor: $cursor) {
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

  const variables = { taskId, limit, cursor }

  return cy.request({
    url,
    method: 'POST',
    body: { query, variables },
    headers: {
      'Content-Type': 'application/json',
      Authorization: 'Bearer ' + idToken,
    },
  })
}
