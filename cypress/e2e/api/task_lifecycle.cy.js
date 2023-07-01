describe('Task lifecycle Test', () => {
  const url = Cypress.env('apiOrigin') + '/graphql'
  const email = Date.now() + '@example.com'

  let idToken
  let taskId

  before(() => {
    cy.task('createUser', email).then((token) => (idToken = token))
  })

  it('Should create a new task', async () => {
    const title = 'New Task'
    const query = `
      mutation Mutation($title: String!) {
        createTask(title: $title) {
          id
          title
          totalWorkingTime
          state
          lastWork {
            id
            startTime
            endTime
            workingTime
          }
        }
      }
    `

    const variables = { title }

    await cy
      .request({
        url,
        method: 'POST',
        body: { query, variables },
        headers: {
          'Content-Type': 'application/json',
          Authorization: 'Bearer ' + idToken,
        },
      })
      .then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body.data.createTask.id).to.not.be.empty
        expect(response.body.data.createTask.title).to.eq(title)
        expect(response.body.data.createTask.state).to.eq('not_started')
        expect(response.body.data.createTask.totalWorkingTime).to.eq(0)

        expect(response.body.data.createTask.lastWork.id).to.be.empty

        taskId = response.body.data.createTask.id
      })
  })

  it('Should start work on a task', async () => {
    const query = `
      mutation Mutation($taskId: ID!) {
        startWorkOnTask(
          taskId: $taskId,
          timestamp: "2022-03-02 20:00"
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

    const variables = { taskId }

    const response = await cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    })

    expect(response.status).to.eq(200)
    expect(response.body.data.startWorkOnTask.state).to.eq('in_progress')
    expect(response.body.data.startWorkOnTask.totalWorkingTime).to.eq(0)

    expect(response.body.data.startWorkOnTask.lastWork.id).to.be.not.empty
    expect(response.body.data.startWorkOnTask.lastWork.startTime).to.be.eq(
      '2022-03-02T20:00:00+00:00'
    )
    expect(response.body.data.startWorkOnTask.lastWork.endTime).to.be.eq(
      '0001-01-01T00:00:00+00:00'
    )
    expect(response.body.data.startWorkOnTask.lastWork.workingTime).to.be.eq(0)
  })

  it('Should stop work on a task', async () => {
    const query = `
      mutation Mutation($taskId: ID!) {
        stopWorkOnTask(
          taskId: $taskId,
          timestamp: "2022-03-02 21:00"
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

    const variables = { taskId }

    const response = await cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    })

    expect(response.status).to.eq(200)
    expect(response.body.data.stopWorkOnTask.state).to.eq('paused')
    expect(response.body.data.stopWorkOnTask.totalWorkingTime).to.eq(3600)

    expect(response.body.data.stopWorkOnTask.lastWork.startTime).to.be.eq(
      '2022-03-02T20:00:00+00:00'
    )
    expect(response.body.data.stopWorkOnTask.lastWork.endTime).to.be.eq(
      '2022-03-02T21:00:00+00:00'
    )
    expect(response.body.data.stopWorkOnTask.lastWork.workingTime).to.be.eq(
      3600
    )
  })

  it('Should resume work on a task', async () => {
    const query = `
      mutation Mutation($taskId: ID!) {
        startWorkOnTask(
          taskId: $taskId,
          timestamp: "2022-03-02 22:00"
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

    const variables = { taskId }

    const response = await cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    })

    expect(response.status).to.eq(200)
    expect(response.body.data.startWorkOnTask.state).to.eq('in_progress')
    expect(response.body.data.startWorkOnTask.totalWorkingTime).to.eq(3600)

    expect(response.body.data.startWorkOnTask.lastWork.startTime).to.be.eq(
      '2022-03-02T22:00:00+00:00'
    )
    expect(response.body.data.startWorkOnTask.lastWork.endTime).to.be.eq(
      '0001-01-01T00:00:00+00:00'
    )
  })

  it('Should complete a task', async () => {
    const query = `
      mutation Mutation($taskId: ID!) {
        completeTask(
          taskId: $taskId,
          timestamp: "2022-03-02 23:00"
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

    const variables = { taskId }

    const response = await cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    })

    expect(response.status).to.eq(200)
    expect(response.body.data.completeTask.state).to.eq('completed')
    expect(response.body.data.completeTask.totalWorkingTime).to.eq(7200)

    expect(response.body.data.completeTask.lastWork.startTime).to.be.eq(
      '2022-03-02T22:00:00+00:00'
    )
    expect(response.body.data.completeTask.lastWork.endTime).to.be.eq(
      '2022-03-02T23:00:00+00:00'
    )
    expect(response.body.data.completeTask.lastWork.workingTime).to.be.eq(3600)
  })
  it('Should complete a task', async () => {
    const query = `
      mutation Mutation($taskId: ID!) {
        completeTask(
          taskId: $taskId,
          timestamp: "2022-03-02 23:00"
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

    const variables = { taskId }

    const response = await cy.request({
      url,
      method: 'POST',
      body: { query, variables },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    })

    expect(response.status).to.eq(200)
    expect(response.body.data.completeTask.state).to.eq('completed')
    expect(response.body.data.completeTask.totalWorkingTime).to.eq(7200)

    expect(response.body.data.completeTask.lastWork.startTime).to.be.eq(
      '2022-03-02T22:00:00+00:00'
    )
    expect(response.body.data.completeTask.lastWork.endTime).to.be.eq(
      '2022-03-02T23:00:00+00:00'
    )
    expect(response.body.data.completeTask.lastWork.workingTime).to.be.eq(3600)
  })
})
