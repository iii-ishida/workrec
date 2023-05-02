import { Form, useLoaderData } from '@remix-run/react'
import { useState, useEffect } from 'react'
import { TaskListItem, taskListItemFromJson } from '~/api-client'
import { SubmitButton } from '~/components/submit-button'
import type { loader } from './task-list.server'

export default function Component() {
  const models = useLoaderData<typeof loader>()

  return (
    <div>
      <TaskList models={models.map(taskListItemFromJson)} />
      <Form method="post" className="my-10 flex">
        <input type="text" name="title" className="grow" />
        <SubmitButton className="flex-none" intent="create">
          Create Task
        </SubmitButton>
      </Form>
    </div>
  )
}

function TaskList({ models }: { models: TaskListItem[] }) {
  const [now, setNow] = useState<Date>(new Date(0))
  useEffect(() => {
    if (!models) {
      return
    }
    setNow(new Date())
  }, [models])

  return (
    <ul>
      {models.map((model) => (
        <li key={model.id}>
          <TaskListRow model={model} now={now} />
        </li>
      ))}
    </ul>
  )
}

function TaskListRow({ model, now }: { model: TaskListItem; now: Date }) {
  return (
    <div className="flex gap-2">
      <p className="grow">{model.title}</p>
      <p className="w-30 flex-none text-right">
        {totalWorkingTimeText(model, now)}
      </p>
      <Form method="post" className="w-14 flex-none text-center">
        <input type="hidden" name="id" value={model.id} />
        <input type="hidden" name="state" value={model.state} />
        <SubmitButton intent="toggle">{toggleButtonText(model)}</SubmitButton>
      </Form>
    </div>
  )
}

function totalWorkingTimeText(task: TaskListItem, now: Date): string {
  if (task.state !== 'in_progress') {
    return `${Math.floor(task.totalWorkingTime / 60)}分`
  }

  if (now.getTime() === 0) {
    return ''
  }

  const workingTime = (now.getTime() - task.lastStartTime.getTime()) / 1000
  return `${Math.floor((task.totalWorkingTime + workingTime) / 60)}分`
}

function toggleButtonText(task: TaskListItem): string {
  switch (task.state) {
    case 'not_started':
    case 'paused':
      return 'start'
    case 'in_progress':
      return 'pause'
    case 'completed':
      return ''
  }
}
