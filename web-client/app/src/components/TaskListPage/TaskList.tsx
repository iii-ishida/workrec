import React from 'react'
import TaskListItem from './TaskListItem'
import styles from './TaskList.module.css'
import { Task, State } from 'src/task'

type Props = {
  userIdToken: string
  tasks: Task[]
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

const TaskList: React.FC<Props> = ({
  userIdToken,
  tasks,
  toggleState,
  finishTask,
  unfinishTask,
  deleteTask,
}: Props) => {
  return (
    <ul className={styles.taskList}>
      {tasks.map((task) => {
        return (
          <li key={task.id}>
            <TaskListItem
              userIdToken={userIdToken}
              task={task}
              toggleState={toggleState}
              finishTask={finishTask}
              unfinishTask={unfinishTask}
              deleteTask={deleteTask}
            />
          </li>
        )
      })}
    </ul>
  )
}

export default TaskList
