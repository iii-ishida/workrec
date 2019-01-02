import React from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'

const WorkListItem = ({ work }) => (
  <span>{work.get('title')}</span>
)

WorkListItem.propTypes = {
  work: PropTypes.instanceOf(Immutable.Map).isRequired
}

export default WorkListItem
