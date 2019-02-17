import { connect } from 'react-redux'
import {
  fetchWorks,
  toggleState,
  finishWork,
  cancelFinishWork,
  deleteWork
} from 'src/actions'

import WorkList from 'src/components/WorkList'

const mapStateToProps = state => ({
  works: state.works.get('works')
})

const mapDispatchToProps = dispatch => ({
  fetchWorks: () => dispatch(fetchWorks()),
  toggleState: (id, currentState, time) => dispatch(toggleState(id, currentState, time)),
  finishWork: (id, time) => dispatch(finishWork(id, time)),
  cancelFinishWork: (id, time) => dispatch(cancelFinishWork(id, time)),
  deleteWork: (id) => dispatch(deleteWork(id))
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(WorkList)
