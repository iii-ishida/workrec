import React from 'react'
import { WorkState } from 'src/api'
import styles from './ToggleStateButton.module.css'

const nextWorkState = (state) => {
  switch (state) {
    case WorkState.UNSTARTED:
      return 'Start'

    case WorkState.STARTED:
      return 'Pause'

    case WorkState.PAUSED:
      return 'Resume'

    case WorkState.RESUMED:
      return 'Pause'

    case WorkState.FINISHED:
      return 'Cancel Finish'

    default:
      return '-'
  }
}

export default function ToggleStateButton({ work, onClick }) {
  return (
    <button className={styles.toggleButton} onClick={onClick}>
      {nextWorkState(work.get('state'))}
    </button>
  )
}
