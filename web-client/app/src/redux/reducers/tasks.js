import Immutable from 'immutable'
import * as ActionTypes from '../actions'

const initialState = Immutable.fromJS({tasks: []})

export const tasks = (state = initialState, action) => {
  switch (action.type) {
  case ActionTypes.RECIEVE_TASKS:
    return Immutable.fromJS({tasks: action.tasks})

  case ActionTypes.DELETE_TASK:
    return state.update('tasks', tasks => {
      return tasks.filter(task => task.get('id') !== action.id)
    })

  default:
    return state
  }
}

