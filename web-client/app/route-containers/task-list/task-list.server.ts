import { ActionArgs, LoaderArgs } from '@remix-run/node'
import {
  createTask,
  fetchTaskList,
  startWorkOnTask,
  stopWorkOnTask,
} from '~/api-client'
import { requireAuth } from '~/services/auth.server'

export async function loader({ request }: LoaderArgs) {
  const sessionCookie = await requireAuth(request)

  return await fetchTaskList(sessionCookie, 10)
}

export async function action({ request }: ActionArgs) {
  const sessionCookie = await requireAuth(request)

  const formData = await request.formData()
  const intent = formData.get('intent')

  switch (intent) {
    case 'create':
      const title = formData.get('title')?.toString() ?? ''
      await createTask(sessionCookie, title)
      return null
    case 'toggle':
      const id = formData.get('id')!.toString()
      const state = formData.get('state')!.toString()
      if (state === 'in_progress') {
        await stopWorkOnTask(sessionCookie, id)
      } else {
        await startWorkOnTask(sessionCookie, id)
      }
      return null
  }
}
