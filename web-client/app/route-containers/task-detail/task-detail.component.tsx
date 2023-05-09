import { useLoaderData } from '@remix-run/react'
import type { loader } from './task-detail.server'
import { WorkSession, taskDetailFromJson } from '~/api-client'

export default function Component() {
  const model = useLoaderData<typeof loader>()
  const task = taskDetailFromJson(model)

  return (
    <div>
      <p>{task.id}</p>
      <p>{task.title}</p>
      <p>
        <WorkSessionList workSessions={task.workSessions} />
      </p>
    </div>
  )
}

function WorkSessionList({ workSessions }: { workSessions: WorkSession[] }) {
  return (
    <ul>
      {workSessions.map((work) => (
        <li key={work.id}>
          <WorkSessionListRow workSession={work} />
        </li>
      ))}
    </ul>
  )
}

function WorkSessionListRow({ workSession }: { workSession: WorkSession }) {
  return (
    <div className="flex gap-2">
      <p className="">{workSession.startTime.toString()}</p>
      <p className="">{workSession.endTime.toString()}</p>
    </div>
  )
}
