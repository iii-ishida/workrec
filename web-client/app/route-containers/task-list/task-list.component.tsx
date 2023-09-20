import { Form, Link, useLoaderData } from '@remix-run/react'
import { useState, useEffect } from 'react'
import { TaskListItem, taskListItemFromJson } from '~/api-client'
import { SubmitButton } from '~/components/submit-button'
import type { loader } from './task-list.server'

export default function Component() {
  const models = useLoaderData<typeof loader>()

  return (
    <div className='container m-md mx-auto'>
      <TaskList models={models.map(taskListItemFromJson)} />
      <Form method="post" className="my-3xl flex gap-xl">
        <input type="text" name="title" className="grow" />
        <SubmitButton className="flex-none btn-primary btn-rounded" intent="create">
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
        <li key={model.id} className='mb-lg'>
          <TaskListRow model={model} now={now} />
        </li>
      ))}
    </ul>
  )
}

function TaskListRow({ model, now }: { model: TaskListItem; now: Date }) {
  return (
    <div className="flex  p-sm rounded-sm gap-xl drop-shadow-md bg-gray-100">
      <Link className="flex grow items-center" to={`/tasks/${model.id}`}>
        <p className="grow">{model.title}</p>
        <p className="w-5xl flex-none text-right">
          {totalWorkingTimeText(model, now)}
        </p>
      </Link>
      <Form method="post" className="flex-none w-4xl text-center">
        <input type="hidden" name="id" value={model.id} />
        <input type="hidden" name="state" value={model.state} />
        <SubmitButton intent="toggle" className='w-full btn-primary rounded-xs py-sm'>{toggleButtonText(model)}</SubmitButton>
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
