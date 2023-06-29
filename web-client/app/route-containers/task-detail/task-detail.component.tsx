import { Form, useLoaderData } from '@remix-run/react'
import type { loader } from './task-detail.server'
import { SubmitButton } from '~/components/submit-button'
import { WorkSession, taskDetailFromJson } from '~/api-client'

export default function Component() {
  const model = useLoaderData<typeof loader>()
  const task = taskDetailFromJson(model)

  return (
    <div>
      <p>{task.id}</p>
      <p>{task.title}</p>
      <p>
        <WorkSessionList taskId={task.id} workSessions={task.workSessions} />
      </p>
    </div>
  )
}

function WorkSessionList({
  taskId,
  workSessions,
}: {
  taskId: string
  workSessions: WorkSession[]
}) {
  return (
    <ul>
      {workSessions.map((work) => (
        <li key={work.id}>
          <WorkSessionListRow workSession={work} />
        </li>
      ))}
      <li key="add">
        <AddWorkSessionListRow taskId={taskId} />
      </li>
    </ul>
  )
}

function WorkSessionListRow({ workSession }: { workSession: WorkSession }) {
  return (
    <Form method="post" className="flex gap-2">
      <input name="id" type="hidden" value={workSession.id} readOnly />
      <input name="startTime" defaultValue={workSession.startTime.toString()} />
      <input name="endTime" defaultValue={workSession.endTime.toString()} />
      <SubmitButton intent="update-work-session">更新</SubmitButton>
    </Form>
  )
}

function AddWorkSessionListRow({ taskId }: { taskId: string }) {
  return (
    <Form method="post" className="flex gap-2">
      <input name="taskId" type="hidden" value={taskId} readOnly />
      <input name="startTime" />
      <input name="endTime" />
      <SubmitButton intent="add-work-session">追加</SubmitButton>
    </Form>
  )
}
