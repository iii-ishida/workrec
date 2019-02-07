import { connect } from 'react-redux'
import { addWork } from 'src/actions'
import AddWork from 'src/components/AddWork'

const mapDispatchToProps = dispatch => ({
  addWork: title => dispatch(addWork(title))
})

export default connect(
  null,
  mapDispatchToProps
)(AddWork)
