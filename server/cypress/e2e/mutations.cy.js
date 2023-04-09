describe("Mutations Test", () => {
  const url = Cypress.env("API_ORIGIN") + "/graphql";
  const email = Date.now() + "@example.com";

  let idToken;
  let taskId;

  before(async () => {
    const response = await cy.request({
      url:
        Cypress.env("FIREBASE_AUTH_ORIGIN") +
        "/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-api-key",
      method: "POST",
      body: { email, password: "PASSWORD", returnSecureToken: true },
    });

    idToken = response.body.idToken;
  });

  it("Should create a new task", async () => {
    const title = "New Task";
    const query = `
      mutation Mutation($title: String!) {
        createTask(title: $title) {
          id
          title
          totalWorkingTime
          state
        }
      }
    `;

    const variables = { title };

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
    expect(response.body.data.createTask.id).to.not.be.empty;
    expect(response.body.data.createTask.title).to.eq(title);
    expect(response.body.data.createTask.state).to.eq("not_started");
    expect(response.body.data.createTask.totalWorkingTime).to.eq(0);

    taskId = response.body.data.createTask.id;
  });

  it("Should start work on a task", async () => {
    const query = `
      mutation Mutation($taskId: String!) {
        startWorkOnTask(
          taskId: $taskId,
          timestamp: "2022-03-02 20:00"
        ) {
          id
          state
          title
          totalWorkingTime
        }
      }
    `;

    const variables = { taskId };

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
    expect(response.body.data.startWorkOnTask.state).to.eq("in_progress");
    expect(response.body.data.startWorkOnTask.totalWorkingTime).to.eq(0);
  });

  it("Should stop work on a task", async () => {
    const query = `
      mutation Mutation($taskId: String!) {
        stopWorkOnTask(
          taskId: $taskId,
          timestamp: "2022-03-02 21:00"
        ) {
          id
          state
          title
          totalWorkingTime
        }
      }
    `;

    const variables = { taskId };

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
    expect(response.body.data.stopWorkOnTask.state).to.eq("paused");
    expect(response.body.data.stopWorkOnTask.totalWorkingTime).to.eq(3600);
  });

  it("Should resume work on a task", async () => {
    const query = `
      mutation Mutation($taskId: String!) {
        startWorkOnTask(
          taskId: $taskId,
          timestamp: "2022-03-02 22:00"
        ) {
          id
          state
          title
          totalWorkingTime
        }
      }
    `;

    const variables = { taskId };

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
    expect(response.body.data.startWorkOnTask.state).to.eq("in_progress");
    expect(response.body.data.startWorkOnTask.totalWorkingTime).to.eq(3600);
  });

  it("Should complete a task", async () => {
    const query = `
      mutation Mutation($taskId: String!) {
        completeTask(
          taskId: $taskId,
          timestamp: "2022-03-02 23:00"
        ) {
          id
          state
          title
          totalWorkingTime
        }
      }
    `;

    const variables = { taskId };

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
    expect(response.body.data.completeTask.state).to.eq("completed");
    expect(response.body.data.completeTask.totalWorkingTime).to.eq(7200);
  });
});
