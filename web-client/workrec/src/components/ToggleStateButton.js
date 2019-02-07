import React from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'
import { WorkState } from 'src/api'

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

const ToggleStateButton = ({ work, onClick }) => {
  const state = work.get('state')

  return (
    <button onClick={onClick}>
      {nextWorkState(state)}
    </button>
  )
}

ToggleStateButton.propTypes = {
  work: PropTypes.instanceOf(Immutable.Map).isRequired,
  onClick: PropTypes.func.isRequired,
}

export default ToggleStateButton

