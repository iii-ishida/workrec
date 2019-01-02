import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Immutable from 'immutable'
import WorkListItem from './WorkListItem'

export default class WorkList extends Component {
  static propTypes = {
    works: PropTypes.instanceOf(Immutable.Iterable).isRequired,
    fetchWorks: PropTypes.func.isRequired,
    deleteWork: PropTypes.func.isRequired
  }

  componentDidMount() {
    this.props.fetchWorks()
  }

  render() {
    const { works = [], deleteWork } = this.props

    return (
      <ul>
        {works.map(work => {
          const workId = work.get('id')

          return (
            <li key={workId}>
              <WorkListItem work={work} deleteWork={deleteWork} />
              <button onClick={() => deleteWork(workId)}>Delete</button>
            </li>
          )
        })}
      </ul>
    )
  }
}

