import React from 'react'
import TaskListItem from './TaskListItem'
import styles from './TaskList.module.css'
import { Task, State } from 'src/workrec'

type Props = {
  tasks: Task[]
  toggleState: (taskId: string, state: State, time: Date) => void
  finishTask: (taskId: string, time: Date) => void
  unfinishTask: (taskId: string, time: Date) => void
  deleteTask: (taskId: string) => void
}

const TaskList: React.FC<Props> = ({
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
