import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'
import ToggleStateButton from './ToggleStateButton'

import * as Work from '../work'
import { WorkState } from '../api'

export default class WorkListItem extends Component {
  static propTypes = {
    work: PropTypes.instanceOf(Immutable.Map).isRequired,
    startWork: PropTypes.func.isRequired,
    pauseWork: PropTypes.func.isRequired,
    resumeWork: PropTypes.func.isRequired,
    finishWork: PropTypes.func.isRequired,
    cancelFinishWork: PropTypes.func.isRequired,
    deleteWork: PropTypes.func.isRequired
  }

  changeWorkState(work) {
    const now = new Date()
    const id = work.get('id')
    const state = work.get('state')

    switch (state) {
    case WorkState.UNSTARTED: return this.props.startWork(id, now)
    case WorkState.STARTED:   return this.props.pauseWork(id, now)
    case WorkState.PAUSED:    return this.props.resumeWork(id, now)
    case WorkState.RESUMED:   return this.props.pauseWork(id, now)
    case WorkState.FINISHED:  return this.props.cancelFinishWork(id, now)
    default:
      // nothing to do
    }
  }

  render() {
    const { work, deleteWork } = this.props
    return (
      <div>
        <span>{work.get('title')}</span>
        <span>{Work.stateText(work)}</span>
        <span>開始時間: {Work.startedAtText(work)}</span>
        <span>作業時間: {Work.workingTimeText(work)}</span>
        <ToggleStateButton onClick={() => this.changeWorkState(work)} work={work} />
        <button onClick={() => deleteWork(work.get('id'))}>Delete</button>
      </div>
    )
  }
}
