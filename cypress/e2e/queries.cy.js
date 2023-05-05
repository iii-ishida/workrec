import { createTask, toggleTask } from "./helper";

describe("Queries Test", () => {
  const url = Cypress.env("API_ORIGIN") + "/graphql";
  const email = Date.now() + "@example.com";
  const count = 10;

  let idToken;
  let cursor;

  let taskIds;

  before(async () => {
    const response = await cy.request({
      url:
        Cypress.env("FIREBASE_AUTH_ORIGIN") +
        "/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key",
      method: "POST",
      body: { email, password: "PASSWORD", returnSecureToken: true },
    });

    idToken = response.body.idToken;
    taskIds = await createTask(idToken, count);
  });

  it("Should get tasks", async () => {
    const limit = count - 1;

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
    `;

    const variables = { limit };

    const response = await cy.request({
      url,
      method: "POST",
      body: { query, variables },
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + idToken,
      },
    });

    expect(response.status).to.eq(200);
    expect(response.body.data.tasks.edges.length).to.eq(limit);
    expect(response.body.data.tasks.pageInfo.endCursor).to.not.be.empty;
    expect(response.body.data.tasks.pageInfo.hasNextPage).to.be.true;

    cursor = response.body.data.tasks.pageInfo.endCursor;
  });

  it("Should get continuation of tasks", async () => {
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
    `;

    const variables = { cursor };

    const response = await cy.request({
      url,
      method: "POST",
      body: { query, variables },
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + idToken,
      },
    });

    expect(response.status).to.eq(200);
    expect(response.body.data.tasks.edges.length).to.eq(1);
    expect(response.body.data.tasks.pageInfo.endCursor).to.be.empty;
    expect(response.body.data.tasks.pageInfo.hasNextPage).to.be.false;
  });

  it("Should get related work sessions on a task", async () => {
    const taskId = taskIds[0];
    await toggleTask(idToken, taskId, new Date(2023, 1, 0, 10), count + 1)

    console.log("TEST_ID", taskId)

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
    `;

    const variables = { taskId, workSessionLimit: count };

    const response = await cy.request({
      url,
      method: "POST",
      body: { query, variables },
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + idToken,
      },
    });

    expect(response.status).to.eq(200);
    expect(response.body.data.task.workSessions.edges.length).to.eq(count);
    expect(response.body.data.task.workSessions.pageInfo.endCursor).to.not.be.empty;
    expect(response.body.data.task.workSessions.pageInfo.hasNextPage).to.be.true;
  });
});
