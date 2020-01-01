import API, { TaskState } from 'src/api'

export const RECIEVE_TASKS = 'RECIEVE_TASKS'
export const START_TASK    = 'START_TASK'
export const PAUSE_TASK    = 'PAUSE_TASK'
export const RESUME_TASK   = 'RESUME_TASK'
export const FINISH_TASK   = 'FINISH_TASK'
export const UNFINISH_TASK = 'UNFINISH_TASK'
export const DELETE_TASK   = 'DELETE_TASK'

const recieveTasks = list => ({
  type: RECIEVE_TASKS,
  tasks: list.tasks
})

export function fetchTasks() {
  return dispatch => {
    return API.getTaskList().then(list => {
      dispatch(recieveTasks(list))
    })
  }
}

export function addTask(title) {
  return dispatch => {
    return API.addTask(title).then(() => dispatch(fetchTasks()))
  }
}

export function toggleState(id, currentState, time) {
  switch (currentState) {
  case TaskState.UNSTARTED: return startTask(id, time)
  case TaskState.STARTED:   return pauseTask(id, time)
  case TaskState.PAUSED:    return resumeTask(id, time)
  case TaskState.RESUMED:   return pauseTask(id, time)
  default:
    // nothing to do
  }
}

function startTask(id, time) {
  return dispatch => {
    return API.startTask(id, time).then(() => dispatch(fetchTasks()))
  }
}

function pauseTask(id, time) {
  return dispatch => {
    return API.pauseTask(id, time).then(() => dispatch(fetchTasks()))
  }
}

function resumeTask(id, time) {
  return dispatch => {
    return API.resumeTask(id, time).then(() => dispatch(fetchTasks()))
  }
}

export function finishTask(id, time) {
  return dispatch => {
    return API.finishTask(id, time).then(() => dispatch(fetchTasks()))
  }
}

export function unfinishTask(id, time) {
  return dispatch => {
    return API.unfinishTask(id, time).then(() => dispatch(fetchTasks()))
  }
}

export function deleteTask(id) {
  return dispatch => {
    return API.deleteTask(id).then(() => {
      dispatch({
        type: DELETE_TASK,
        id
      })
    })
  }
}

