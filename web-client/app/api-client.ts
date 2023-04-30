export interface TaskListItem {
  id: string
  title: string
  totalWorkingTime: number
  state: 'not_started' | 'in_progress' | 'paused' | 'completed'
  lastStartTime: Date
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

  return await fetch('http://localhost:8080/graphql', {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${sessionCookie}`,
    },
    method: 'POST',
    body: JSON.stringify({
      query,
      variables: { limit, cursor },
    }),
  })
    .then((res) => res.json())
    .then((result) => {
      if (result.errors) {
        throw result.errors
      }

      return result.data.tasks.edges.map((edge: any) => {
        const node = edge.node
        return {
          id: node.id,
          title: node.title,
          totalWorkingTime: node.totalWorkingTime,
          state: node.state,
          lastStartTime: node.lastWork
            ? new Date(node.lastWork.startTime)
            : null,
        }
      })
    })
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

  await fetch('http://localhost:8080/graphql', {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${sessionCookie}`,
    },
    method: 'POST',
    body: JSON.stringify({
      query,
      variables: { title },
    }),
  })
}
