import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'
import ToggleStateButton from 'src/components/ToggleStateButton'

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
      <div>
        <span>{work.get('title')}</span>
        <span>{Work.stateText(work)}</span>
        <span>開始時間: {Work.startedAtText(work)}</span>
        <span>作業時間: {Work.workingTimeText(work)}</span>
        <ToggleStateButton onClick={() => this.onToggleState(work)} work={work} />
        <button onClick={() => deleteWork(work.get('id'))}>Delete</button>
      </div>
    )
  }
}
