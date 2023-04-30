import { ActionArgs, LoaderArgs } from '@remix-run/node'
import { Form, useLoaderData } from '@remix-run/react'
import { createTask, fetchTaskList } from '~/api-client'
import { requireAuth } from '~/services/auth.server'

interface Model {
  id: string
  title: string
  state: string
  totalWorkingTime: number
}

export async function loader({ request }: LoaderArgs) {
  const sessionCookie = await requireAuth(request)

  const tasks = await fetchTaskList(sessionCookie, 10)
  return tasks.map((task) => ({
    id: task.id,
    title: task.title,
    state: task.state,
    totalWorkingTime: task.totalWorkingTime,
  }))
}

export async function action({ request }: ActionArgs) {
  const sessionCookie = await requireAuth(request)

  await createTask(sessionCookie, 'New Task')
  return null
}

export default function Component() {
  const models = useLoaderData<typeof loader>()
  return (
    <div>
      <ul>
        {models.map((model) => (
          <li key={model.id}>
            <TaskListRow model={model} />
          </li>
        ))}
      </ul>

      <Form method="post">
        <button type="submit">Create Task</button>
      </Form>
    </div>
  )
}

function TaskListRow({ model }: { model: Model }) {
  return (
    <div>
      <div>{model.title}</div>
      <div>{model.state}</div>
      <div>{model.totalWorkingTime}</div>
    </div>
  )
}
