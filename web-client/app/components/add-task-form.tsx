import { Form } from '@remix-run/react'
import { SubmitButton } from '~/components/submit-button'

export function AddTaskForm({ intent }: { intent: string }) {
  return (
    <Form method="post" className="flex gap-5">
      <input type="text" name="title" className="grow" />
      <SubmitButton
        className="btn-primary btn-rounded flex-none"
        intent={intent}
      >
        Create Task
      </SubmitButton>
    </Form>
  )
}
