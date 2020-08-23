import React from 'react'
import TaskList from './TaskList'
import AddTask from './AddTask'
import { Task, State } from 'src/workrec'

type Props = {
  userIdToken: string
  tasks: Task[]
  addTask: (userIdToken: string, title: string) => void
  toggleState: (
    userIdToken: string,
    taskId: string,
    state: State,
    time: Date
  ) => void
  finishTask: (userIdToken: string, taskId: string, time: Date) => void
  unfinishTask: (userIdToken: string, taskId: string, time: Date) => void
  deleteTask: (userIdToken: string, taskId: string) => void
}

const TaskListPage: React.FC<Props> = ({
  userIdToken,
  tasks,
  addTask,
  toggleState,
  finishTask,
  unfinishTask,
  deleteTask,
}: Props) => {
  return (
    <div>
      <TaskList
        userIdToken={userIdToken}
        tasks={tasks}
        toggleState={toggleState}
        finishTask={finishTask}
        unfinishTask={unfinishTask}
        deleteTask={deleteTask}
      />

      <AddTask userIdToken={userIdToken} addTask={addTask} />
    </div>
  )
}

export default TaskListPage
