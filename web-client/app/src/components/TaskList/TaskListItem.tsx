import React from 'react'
import ToggleStateButton from 'src/components/ToggleStateButton'
import styles from './TaskListItem.module.css'

import { Task as TaskModel } from 'src/task'
import * as Task from 'src/task'

type Props = {
  task: TaskModel
  toggleState: (string, State, Date) => void
  finishTask: (string, Date) => void
  unfinishTask: (string, Date) => void
  deleteTask: (string) => void
}

const TaskListItem: React.FC<Props> = ({
  task,
  toggleState,
  finishTask,
  unfinishTask,
  deleteTask,
}: Props) => {
  const onToggleState = task => {
    const now = new Date()
    const id = task.id
    const state = task.state

    toggleState(id, state, now)
  }

  return (
    <div className={styles.taskListItem}>
      <dl className={styles.contents}>
        <div className={styles.title}>
          <dt>タイトル</dt>
          <dd>{task.title}</dd>
        </div>
        <div className={styles.startTime}>
          <dt>開始時間</dt>
          <dd>{Task.startedAtText(task)}</dd>
        </div>
        <div className={styles.workingTime}>
          <dt>作業時間</dt>
          <dd>{Task.workingTimeText(task)}</dd>
        </div>
      </dl>

      <div className={styles.actions}>
        <ToggleStateButton onClick={() => onToggleState(task)} task={task} />
        <button
          className={styles.deleteButton}
          onClick={() => deleteTask(task.id)}
        >
          Delete
        </button>
      </div>
    </div>
  )
}

export default TaskListItem
