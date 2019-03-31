import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'
import WorkListItem from './WorkListItem'
import styles from './WorkList.module.css'

export default class WorkList extends Component {
  static propTypes = {
    works: PropTypes.instanceOf(Immutable.Iterable).isRequired,
    fetchWorks: PropTypes.func.isRequired,
    toggleState: PropTypes.func.isRequired,
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
      toggleState,
      finishWork,
      cancelFinishWork,
      deleteWork
    } = this.props

    return (
      <ul className={styles.workList}>
        {works.map(work => {
          return (
            <li key={work.get('id')}>
              <WorkListItem
                work={work}
                toggleState={toggleState}
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
