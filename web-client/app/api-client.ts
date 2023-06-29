export type TaskState = 'not_started' | 'in_progress' | 'paused' | 'completed'

export interface TaskListItem {
  id: string
  title: string
  totalWorkingTime: number
  state: TaskState
  lastStartTime: Date
}

export interface WorkSession {
  id: string
  startTime: Date
  endTime: Date
}

export interface TaskDetail {
  id: string
  title: string
  totalWorkingTime: number
  state: TaskState
  workSessions: WorkSession[]
}

export function taskDetailFromJson(obj: any): TaskDetail {
  return {
    id: obj.id,
    title: obj.title,
    totalWorkingTime: obj.totalWorkingTime,
    state: obj.state,
    workSessions: obj.workSessions,
  }
}

export function workSessionFromJson(obj: any): WorkSession {
  return {
    id: obj.id,
    startTime: obj.startTime ? new Date(obj.startTime) : new Date(0),
    endTime: obj.endTime ? new Date(obj.endTime) : new Date(0),
  }
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

export async function fetchTaskDetail(
  sessionCookie: string,
  taskId: string,
  workSessionLimit: number,
  workSessionCursor?: string
): Promise<TaskDetail> {
  const query = `
  query TaskDetail($taskId: ID!, $workSessionLimit: Int!, $workSessionCursor: String) {
    task(id: $taskId) {
      id
      state
      title
      totalWorkingTime
      workSessions(limit: $workSessionLimit, cursor: $workSessionCursor) {
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

  const variables = { taskId, workSessionLimit, workSessionCursor }

  return await fetchGraphql({ query, variables, sessionCookie }).then(
    (result) => {
      return taskDetailFromJson({
        ...result.data.task,
        workSessions: result.data.task.workSessions.edges.map((edge: any) =>
          workSessionFromJson(edge.node)
        ),
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

export async function addWorkSession(
  sessionCookie: string,
  taskId: string,
  startTime: Date,
  endTime: Date
): Promise<void> {
  const query = `
  mutation AddWorkSession($taskId: String!, $startTime: DateTime!, $endTime: DateTime!) {
  addWorkSession(taskId: $taskId, startTime: $startTime, endTime: $endTime) {
      id
      startTime
      endTime
    }
  }
`

  const variables = { taskId, startTime, endTime }
  await fetchGraphql({ query, variables, sessionCookie })
}

export async function updateWorkSession(
  sessionCookie: string,
  id: string,
  startTime: Date,
  endTime: Date
): Promise<void> {
  const query = `
  mutation EditWorkSession($workSessionId: String!, $startTime: DateTime!, $endTime: DateTime!) {
  editWorkSession(workSessionId: $workSessionId, startTime: $startTime, endTime: $endTime) {
      id
      startTime
      endTime
    }
  }
`

  const variables = { workSessionId: id, startTime, endTime }
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
  const url = `${process.env.API_ORIGIN}/graphql`
  return await fetch(url, {
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
