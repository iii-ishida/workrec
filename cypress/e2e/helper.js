const url = Cypress.env("API_ORIGIN") + "/graphql";

export async function createTask(idToken, count) {
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

  const requests = [...Array(count)].map((i) =>
    fetch(url, {
      method: "POST",
      body: JSON.stringify({ query, variables: { title: `task ${i + 1}` } }),
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + idToken,
      },
    }).then((res) => {
      return res.json();
    })
  );

  const taskIds = [];
  for await (let response of requests) {
    taskIds.push(response.data.createTask.id);
  }
  return taskIds;
}

export async function startTask(idToken, taskId, timestamp) {
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
    `;

  const variables = { taskId, timestamp };

  return await fetch(url, {
    method: "POST",
    body: JSON.stringify({ query, variables }),
    headers: {
      "Content-Type": "application/json",
      Authorization: "Bearer " + idToken,
    },
  }).then((res) => res.json());
}

export async function stopTask(idToken, taskId, timestamp) {
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
    `;

  const variables = { taskId, timestamp };

  return await fetch(url, {
    method: "POST",
    body: JSON.stringify({ query, variables }),
    headers: {
      "Content-Type": "application/json",
      Authorization: "Bearer " + idToken,
    },
  }).then((res) => res.json());
}

export async function toggleTask(idToken, taskId, timestamp, count) {
  for (let i = 0; i < count; i++) {
    await startTask(idToken, taskId, new Date(timestamp.getTime() + (i * 2) * 1000 * 60))
    await stopTask(idToken, taskId, new Date(timestamp.getTime() + (i * 2 + 1) * 1000 * 60))
  }
}


export async function getTask(idToken, taskId) {
  const query = `
      query Query($taskId: ID!) {
        task(id: $taskId){
          id
          state
          title
          totalWorkingTime
        }
      }
    `;

  const response = await fetch(url, {
    method: "POST",
    body: JSON.stringify({ query, variables: { taskId } }),
    headers: {
      "Content-Type": "application/json",
      Authorization: "Bearer " + idToken,
    },
  }).then((res) => res.json());

  return response;
}
