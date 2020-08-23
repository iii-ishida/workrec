import React from 'react'
import styles from './ToggleStateButton.module.css'
import { Task, State } from 'src/workrec'

const nextTaskState = (state: State) => {
  switch (state) {
    case 'UNSTARTED':
      return 'Start'
    case 'STARTED':
      return 'Pause'
    case 'PAUSED':
      return 'Resume'
    case 'RESUMED':
      return 'Pause'
    case 'FINISHED':
      return 'Unfinish'
    default:
      return '-'
  }
}

type Props = {
  task: Task
  onClick: () => void
}

const ToggleStateButton: React.FC<Props> = ({ task, onClick }: Props) => (
  <button className={styles.toggleButton} onClick={onClick}>
    {nextTaskState(task.state)}
  </button>
)

export default ToggleStateButton
