import API from '../api'

export const RECIEVE_WORKS = 'RECIEVE_WORKS'
export const DELETE_WORK = 'DELETE_WORK'

const recieveWorks = worklist => ({
  type: RECIEVE_WORKS,
  works: worklist.works
})

export function fetchWorks() {
  return dispatch => {
    return API.getWorkList().then(worklist => {
      dispatch(recieveWorks(worklist))
    })
  }
}

export function addWork(title) {
  return dispatch => {
    return API.addWork(title).then(() => dispatch(fetchWorks()))
  }
}


export function deleteWork(id) {
  return dispatch => {
    return API.deleteWork(id).then(() => {
      dispatch({
        type: DELETE_WORK,
        id
      })
    })
  }
}

