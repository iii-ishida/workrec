import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'
import ToggleStateButton from 'src/components/ToggleStateButton'
import styles from './WorkListItem.module.css'

import * as Work from 'src/work'

export default class WorkListItem extends Component {
  static propTypes = {
    work: PropTypes.instanceOf(Immutable.Map).isRequired,
    toggleState: PropTypes.func.isRequired,
    finishWork: PropTypes.func.isRequired,
    cancelFinishWork: PropTypes.func.isRequired,
    deleteWork: PropTypes.func.isRequired
  }

  onToggleState(work) {
    const now = new Date()
    const id = work.get('id')
    const state = work.get('state')

    this.props.toggleState(id, state, now)
  }

  render() {
    const { work, deleteWork } = this.props
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
          <ToggleStateButton onClick={() => this.onToggleState(work)} work={work} />
          <button className={styles.deleteButton} onClick={() => deleteWork(work.get('id'))}>Delete</button>
        </div>
      </div>
    )
  }
}
