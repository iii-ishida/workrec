import { createStore, applyMiddleware } from 'redux'
import thunk from 'redux-thunk'
import { devReducer }  from 'src/reducers'

const configureStore = () => createStore(
  devReducer,
  applyMiddleware(thunk)
)

export default configureStore