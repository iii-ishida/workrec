import { ActionArgs, LoaderArgs } from '@remix-run/node'
import {
  fetchTaskDetail,
  addWorkSession,
  updateWorkSession,
} from '~/api-client'
import { requireAuth } from '~/services/auth.server'

export async function loader({ request, params }: LoaderArgs) {
  const sessionCookie = await requireAuth(request)

  return await fetchTaskDetail(sessionCookie, params.taskId!, 10)
}

export async function action({ request }: ActionArgs) {
  const sessionCookie = await requireAuth(request)

  const formData = await request.formData()
  const intent = formData.get('intent')

  switch (intent) {
    case 'add-work-session':
      await onAddWorkSession(sessionCookie, formData)
      return null

    case 'update-work-session':
      await onUpdateWorkSession(sessionCookie, formData)
      return null
  }
}

async function onAddWorkSession(sessionCookie: string, formData: any) {
  const id = formData.get('taskId')?.toString() ?? ''
  const startTime = formData.get('startTime')?.toString() ?? ''
  const endTime = formData.get('endTime')?.toString() ?? ''
  await addWorkSession(
    sessionCookie,
    id,
    new Date(startTime),
    new Date(endTime)
  )
}

async function onUpdateWorkSession(sessionCookie: string, formData: any) {
  const id = formData.get('id')?.toString() ?? ''
  const startTime = formData.get('startTime')?.toString() ?? ''
  const endTime = formData.get('endTime')?.toString() ?? ''
  await updateWorkSession(
    sessionCookie,
    id,
    new Date(startTime),
    new Date(endTime)
  )
}
