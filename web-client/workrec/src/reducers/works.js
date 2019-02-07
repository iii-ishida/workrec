import Immutable from 'immutable'
import * as ActionTypes from 'src/actions'

const initialState = Immutable.fromJS({works: []})

export const works = (state = initialState, action) => {
  switch (action.type) {
    case ActionTypes.RECIEVE_WORKS:
      return Immutable.fromJS({works: action.works})

    case ActionTypes.DELETE_WORK:
      return state.update('works', works => {
        return works.filter(work => work.get('id') !== action.id)
      })

    default:
      return state
  }
}

