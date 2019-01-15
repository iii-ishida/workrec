import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'
import WorkListItem from './WorkListItem'

export default class WorkList extends Component {
  static propTypes = {
    works: PropTypes.instanceOf(Immutable.Iterable).isRequired,
    fetchWorks: PropTypes.func.isRequired,
    startWork: PropTypes.func.isRequired,
    pauseWork: PropTypes.func.isRequired,
    resumeWork: PropTypes.func.isRequired,
    finishWork: PropTypes.func.isRequired,
    cancelFinishWork: PropTypes.func.isRequired,
    deleteWork: PropTypes.func.isRequired
  }

  componentDidMount() {
    this.props.fetchWorks()
  }

  render() {
    const {
      works = [],
      startWork,
      pauseWork,
      resumeWork,
      finishWork,
      cancelFinishWork,
      deleteWork
    } = this.props

    return (
      <ul>
        {works.map(work => {
          return (
            <li key={work.get('id')}>
              <WorkListItem
                work={work}
                startWork={startWork}
                pauseWork={pauseWork}
                resumeWork={resumeWork}
                finishWork={finishWork}
                cancelFinishWork={cancelFinishWork}
                deleteWork={deleteWork}
              />
            </li>
          )
        })}
      </ul>
    )
  }
}

