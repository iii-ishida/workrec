import API, { WorkState } from 'src/api'

export const RECIEVE_WORKS = 'RECIEVE_WORKS'
export const START_WORK    = 'START_WORK'
export const PAUSE_WORK    = 'PAUSE_WORK'
export const RESUME_WORK   = 'RESUME_WORK'
export const FINISH_WORK   = 'FINISH_WORK'
export const UNFINISH_WORK = 'UNFINISH_WORK'
export const DELETE_WORK   = 'DELETE_WORK'

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

export function toggleState(id, currentState, time) {
  switch (currentState) {
  case WorkState.UNSTARTED: return startWork(id, time)
  case WorkState.STARTED:   return pauseWork(id, time)
  case WorkState.PAUSED:    return resumeWork(id, time)
  case WorkState.RESUMED:   return pauseWork(id, time)
  default:
    // nothing to do
  }
}

function startWork(id, time) {
  return dispatch => {
    return API.startWork(id, time).then(() => dispatch(fetchWorks()))
  }
}

function pauseWork(id, time) {
  return dispatch => {
    return API.pauseWork(id, time).then(() => dispatch(fetchWorks()))
  }
}

function resumeWork(id, time) {
  return dispatch => {
    return API.resumeWork(id, time).then(() => dispatch(fetchWorks()))
  }
}

export function finishWork(id, time) {
  return dispatch => {
    return API.finishWork(id, time).then(() => dispatch(fetchWorks()))
  }
}

export function unfinishWork(id, time) {
  return dispatch => {
    return API.unfinishWork(id, time).then(() => dispatch(fetchWorks()))
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

