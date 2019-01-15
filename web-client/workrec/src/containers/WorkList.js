import { connect } from 'react-redux'
import {
  fetchWorks,
  startWork,
  pauseWork,
  resumeWork,
  finishWork,
  cancelFinishWork,
  deleteWork
} from '../actions'

import WorkList from '../components/WorkList'

const mapStateToProps = state => ({
  works: state.works.get('works')
})

const mapDispatchToProps = dispatch => ({
  fetchWorks: () => dispatch(fetchWorks()),
  startWork: (id, time) => dispatch(startWork(id, time)),
  pauseWork: (id, time) => dispatch(pauseWork(id, time)),
  resumeWork: (id, time) => dispatch(resumeWork(id, time)),
  finishWork: (id, time) => dispatch(finishWork(id, time)),
  cancelFinishWork: (id, time) => dispatch(cancelFinishWork(id, time)),
  deleteWork: (id) => dispatch(deleteWork(id))
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(WorkList)
