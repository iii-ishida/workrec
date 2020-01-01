import React, { useEffect } from 'react'

import TaskListItem from './TaskListItem'
import styles from './TaskList.module.css'

export default function TaskList({tasks, fetchTasks, toggleState, finishTask, unfinishTask, deleteTask}) {
  useEffect(
    () => {
      fetchTasks()
    },
    [fetchTasks]
  )

  return (
    <ul className={styles.taskList}>
      {tasks.map(task => {
        return (
          <li key={task.get('id')}>
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
