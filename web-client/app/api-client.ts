export interface TaskListItem {
  id: string
  title: string
  totalWorkingTime: number
  state: 'not_started' | 'in_progress' | 'paused' | 'completed'
  lastStartTime: Date
}

export function taskListItemFromJson(obj: any): TaskListItem {
  return {
    id: obj.id,
    title: obj.title,
    totalWorkingTime: obj.totalWorkingTime,
    state: obj.state,
    lastStartTime: obj.lastStartTime
      ? new Date(obj.lastStartTime)
      : new Date(0),
  }
}

export async function fetchTaskList(
  sessionCookie: string,
  limit: number,
  cursor: string = ''
): Promise<TaskListItem[]> {
  const query = `
  query TaskList($limit: Int!, $cursor: String) {
    tasks(limit: $limit, cursor: $cursor) {
      edges {
        node {
          id
          state
          title
          totalWorkingTime
          lastWork {
            startTime
          }
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

  return await fetchGraphql({ query, variables, sessionCookie }).then(
    (result) => {
      return result.data.tasks.edges.map((edge: any) => {
        return taskListItemFromJson({
          ...edge.node,
          lastStartTime: edge.node.lastWork?.startTime,
        })
      })
    }
  )
}

export async function createTask(
  sessionCookie: string,
  title: string
): Promise<void> {
  const query = `
  mutation CreateTask($title: String!) {
    createTask(title: $title) {
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
  const variables = { title }

  await fetchGraphql({ query, variables, sessionCookie })
}

export async function startWorkOnTask(
  sessionCookie: string,
  id: string
): Promise<void> {
  const query = `
  mutation StartWorkOnTask($taskId: String!, $timestamp: DateTime!) {
    startWorkOnTask(taskId: $taskId, timestamp: $timestamp) {
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

  const variables = { taskId: id, timestamp: new Date().toISOString() }
  await fetchGraphql({ query, variables, sessionCookie })
}

export async function stopWorkOnTask(
  sessionCookie: string,
  id: string
): Promise<void> {
  const query = `
  mutation StopWorkOnTask($taskId: String!, $timestamp: DateTime!) {
    stopWorkOnTask(taskId: $taskId, timestamp: $timestamp) {
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

  const variables = { taskId: id, timestamp: new Date().toISOString() }
  await fetchGraphql({ query, variables, sessionCookie })
}

async function fetchGraphql({
  sessionCookie,
  query,
  variables,
}: {
  sessionCookie: string
  query: string
  variables: any
}): Promise<any> {
  return await fetch('http://localhost:8080/graphql', {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${sessionCookie}`,
    },
    method: 'POST',
    body: JSON.stringify({
      query,
      variables,
    }),
  })
    .then((res) => res.json())
    .then((result) => {
      if (result.errors) {
        console.error(result)
        throw result.errors
      }
      return result
    })
}
