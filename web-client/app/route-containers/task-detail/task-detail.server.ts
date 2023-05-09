import { LoaderArgs } from '@remix-run/node'
import { fetchTaskDetail } from '~/api-client'
import { requireAuth } from '~/services/auth.server'

export async function loader({ request, params }: LoaderArgs) {
  const sessionCookie = await requireAuth(request)

  return await fetchTaskDetail(sessionCookie, params.taskId!, 10)
}

export async function action() {
  return null
}
