import React, { useEffect } from 'react'
import TaskListItem from './TaskListItem'
import styles from './TaskList.module.css'
import { Task } from 'src/task'

type Props = {
  tasks: Task[]
  fetchTasks: () => void
  toggleState: (string, State, Date) => void
  finishTask: (string, Date) => void
  unfinishTask: (string, Date) => void
  deleteTask: (string) => void
}

const TaskList: React.FC<Props> = ({
  tasks,
  fetchTasks,
  toggleState,
  finishTask,
  unfinishTask,
  deleteTask,
}: Props) => {
  useEffect(() => {
    fetchTasks()
  }, [fetchTasks])

  return (
    <ul className={styles.taskList}>
      {tasks.map(task => {
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
