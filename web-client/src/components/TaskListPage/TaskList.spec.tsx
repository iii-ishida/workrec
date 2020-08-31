import '@testing-library/jest-dom'
import React from 'react'
import { render } from '@testing-library/react'

import TaskList from './TaskList'
import TaskListItem from './TaskListItem'
import { Task } from 'src/workrec'

describe('TaskList', () => {
  it('tasks の分 TaskListItem を表示すること', () => {
    const now = new Date()
    const tasks = [
      {
        id: 'someid01',
        title: '',
        state: 'UNSTARTED',
        createdAt: now,
        updatedAt: now,
      } as Task,
      {
        id: 'someid02',
        title: '',
        state: 'UNSTARTED',
        createdAt: now,
        updatedAt: now,
      } as Task,
      {
        id: 'someid03',
        title: '',
        state: 'UNSTARTED',
        createdAt: now,
        updatedAt: now,
      } as Task,
    ]

    const { container } = render(
      <TaskList
        tasks={tasks}
        toggleState={() => {}}
        finishTask={() => {}}
        unfinishTask={() => {}}
        deleteTask={() => {}}
      />
    )

    expect(container.querySelectorAll('li').length).toBe(3)
  })
})
