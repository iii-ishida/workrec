import { createTask, startTask, getTask } from "./helper";

describe("Start Test", () => {
  const url = Cypress.env("API_ORIGIN") + "/graphql";
  const email = Date.now() + "@example.com";

  let idToken;
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
    taskIds = await createTask(idToken, 10);
  });

  it("Should stop other tasks", async () => {
    const anotherTaskId = taskIds[0];
    const targetTaskId = taskIds[1];

    await startTask(idToken, anotherTaskId, new Date().toISOString());
    await startTask(idToken, targetTaskId, new Date().toISOString());

    const targetTaskResponse = await getTask(idToken, targetTaskId);
    const anotherTaskResponse = await getTask(idToken, anotherTaskId);

    expect(targetTaskResponse.data.task.state).to.eq("in_progress");
    expect(anotherTaskResponse.data.task.state).to.eq("paused");
  });
});
