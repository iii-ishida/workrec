import React from 'react'
import ToggleStateButton from 'src/components/ToggleStateButton'
import styles from './TaskListItem.module.css'

import * as Task from 'src/task'

export default function TaskListItem({ task, toggleState, finishTask, unfinishTask, deleteTask }) {
  const onToggleState = (task) => {
    const now = new Date()
    const id = task.get('id')
    const state = task.get('state')

    toggleState(id, state, now)
  }

  return (
    <div className={styles.taskListItem}>
      <dl className={styles.contents}>
        <div className={styles.title}>
          <dt>タイトル</dt>
          <dd>{task.get('title')}</dd>
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
        <button className={styles.deleteButton} onClick={() => deleteTask(task.get('id'))}>Delete</button>
      </div>
    </div>
  )
}
