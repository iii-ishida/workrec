import { connect } from 'react-redux'
import { addWork } from '../actions'
import AddWork from '../components/AddWork'

const mapDispatchToProps = dispatch => ({
  addWork: title => dispatch(addWork(title))
})

export default connect(
  null,
  mapDispatchToProps
)(AddWork)
