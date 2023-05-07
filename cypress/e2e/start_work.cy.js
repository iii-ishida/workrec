describe('Start Test', () => {
  const url = Cypress.env('apiOrigin') + '/graphql'
  const email = Date.now() + '@example.com'

  let idToken
  let taskIds

  before(() => {
    cy.task('createUser', email).then((token) => (idToken = token))
    cy.task('createTasks', { email, count: 2 }).then((ids) => (taskIds = ids))
  })

  it('Should stop other tasks', async () => {
    const anotherTaskId = taskIds[0]
    const targetTaskId = taskIds[1]

    cy.task('startTask', {
      idToken,
      taskId: anotherTaskId,
      timestamp: new Date().toISOString(),
    })
    cy.task('startTask', {
      idToken,
      taskId: targetTaskId,
      timestamp: new Date().toISOString(),
    })

    const query = `
      query Query($taskId: ID!) {
        task(id: $taskId){
          id
          state
          title
          totalWorkingTime
        }
      }
    `

    cy.request({
      url,
      method: 'POST',
      body: { query, variables: { taskId: targetTaskId } },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    }).then((res) => {
      expect(res.body.data.task.state).to.eq('in_progress')
    })

    cy.request({
      url,
      method: 'POST',
      body: { query, variables: { taskId: anotherTaskId } },
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'Bearer ' + idToken,
      },
    }).then((res) => {
      expect(res.body.data.task.state).to.eq('paused')
    })
  })
})
