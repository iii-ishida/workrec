import React from 'react'
import ToggleStateButton from 'src/components/ToggleStateButton'
import styles from './WorkListItem.module.css'

import * as Work from 'src/work'

export default function WorkListItem({ work, toggleState, finishWork, cancelFinishWork, deleteWork }) {
  const onToggleState = (work) => {
    const now = new Date()
    const id = work.get('id')
    const state = work.get('state')

    toggleState(id, state, now)
  }

  return (
    <div className={styles.workListItem}>
      <dl className={styles.contents}>
        <div className={styles.title}>
          <dt>タイトル</dt>
          <dd>{work.get('title')}</dd>
        </div>
        <div className={styles.startTime}>
          <dt>開始時間</dt>
          <dd>{Work.startedAtText(work)}</dd>
        </div>
        <div className={styles.workingTime}>
          <dt>作業時間</dt>
          <dd>{Work.workingTimeText(work)}</dd>
        </div>
      </dl>

      <div className={styles.actions}>
        <ToggleStateButton onClick={() => onToggleState(work)} work={work} />
        <button className={styles.deleteButton} onClick={() => deleteWork(work.get('id'))}>Delete</button>
      </div>
    </div>
  )
}
