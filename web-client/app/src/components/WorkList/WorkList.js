import React, { useEffect } from 'react'

import WorkListItem from './WorkListItem'
import styles from './WorkList.module.css'

export default function WorkList({works, fetchWorks, toggleState, finishWork, unfinishWork, deleteWork}) {
  useEffect(
    () => {
      fetchWorks()
    },
    []
  )

  return (
    <ul className={styles.workList}>
      {works.map(work => {
        return (
          <li key={work.get('id')}>
            <WorkListItem
                work={work}
                toggleState={toggleState}
                finishWork={finishWork}
                unfinishWork={unfinishWork}
                deleteWork={deleteWork}
            />
          </li>
        )
      })}
    </ul>
  )
}
