import { connect } from 'react-redux'
import { fetchWorks, deleteWork } from '../actions'
import WorkList from '../components/WorkList'

const mapStateToProps = state => ({
  works: state.works.get('works')
})

const mapDispatchToProps = dispatch => ({
  fetchWorks: () => dispatch(fetchWorks()),
  deleteWork: id => dispatch(deleteWork(id))
})

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(WorkList)
