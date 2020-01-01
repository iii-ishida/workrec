import React from 'react'
import { TaskState } from 'src/api'
import styles from './ToggleStateButton.module.css'

const nextTaskState = (state) => {
  switch (state) {
  case TaskState.UNSTARTED:
    return 'Start'

  case TaskState.STARTED:
    return 'Pause'

  case TaskState.PAUSED:
    return 'Resume'

  case TaskState.RESUMED:
    return 'Pause'

  case TaskState.FINISHED:
    return 'Unfinish'

  default:
    return '-'
  }
}

export default function ToggleStateButton({ task, onClick }) {
  return (
    <button className={styles.toggleButton} onClick={onClick}>
      {nextTaskState(task.get('state'))}
    </button>
  )
}
