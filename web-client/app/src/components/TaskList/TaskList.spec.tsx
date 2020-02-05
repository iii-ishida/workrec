import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import TaskList from './TaskList'
import TaskListItem from './TaskListItem'
import { Task } from 'src/task'

Enzyme.configure({ adapter: new Adapter() })

describe('<TaskList />', () => {
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

    const taskList = shallow(
      <TaskList
        userIdToken="some-user-id-token"
        tasks={tasks}
        fetchTasks={() => {}}
        toggleState={() => {}}
        finishTask={() => {}}
        unfinishTask={() => {}}
        deleteTask={() => {}}
      />
    )

    expect(taskList.find(TaskListItem).length).toBe(3)
  })

  it('TaskListItem に task を設定すること', () => {
    const now = new Date()
    const task = {
      id: 'someid01',
      title: 'some title',
      state: 'UNSTARTED',
      createdAt: now,
      updatedAt: now,
    } as Task
    const tasks = [task]

    const fetchTasks = () => {}
    const toggleState = () => {}
    const finishTask = () => {}
    const unfinishTask = () => {}
    const deleteTask = () => {}

    const taskList = shallow(
      <TaskList
        userIdToken="some-user-id-token"
        tasks={tasks}
        fetchTasks={fetchTasks}
        toggleState={toggleState}
        finishTask={finishTask}
        unfinishTask={unfinishTask}
        deleteTask={deleteTask}
      />
    )

    const taskListItem = taskList.find(TaskListItem)
    expect(taskListItem.props().task).toBe(task)
    expect(taskListItem.props().toggleState).toBe(toggleState)
    expect(taskListItem.props().finishTask).toBe(finishTask)
    expect(taskListItem.props().unfinishTask).toBe(unfinishTask)
    expect(taskListItem.props().deleteTask).toBe(deleteTask)
  })
})
