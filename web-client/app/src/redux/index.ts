import { createSlice, configureStore  } from '@reduxjs/toolkit'
import API, { TaskState } from 'src/api'

const tasks = createSlice({
  name: 'tasks',
  initialState: [],
  reducers: {
    recieveTasks: (_, action) => action.payload.tasks,
    deleteTask: (state, action) => state.filter(task => task.id !== action.payload)
  }
})

export const fetchTasks = () => async dispatch => {
  const list = await API.getTaskList()
  dispatch(tasks.actions.recieveTasks(list))
}

export const addTask = title => async dispatch => {
  await API.addTask(title)
  dispatch(fetchTasks())
}

export const toggleState = (id, currentState, time) => async dispatch => {
  const toggleAPI = {
    [TaskState.UNSTARTED]: API.startTask,
    [TaskState.STARTED]: API.pauseTask,
    [TaskState.PAUSED]: API.resumeTask,
    [TaskState.RESUMED]: API.pauseTask
  }

  await toggleAPI[currentState](id, time)
  dispatch(fetchTasks())
}

export const finishTask = (id, time) => async dispatch => {
  await API.finishTask(id, time)
  dispatch(fetchTasks())
}

export const unfinishTask = (id, time) => async dispatch => {
  await API.unfinishTask(id, time)
  dispatch(fetchTasks())
}

export const deleteTask = (id) => async dispatch => {
  await API.deleteTask(id)
  dispatch(tasks.actions.deleteTask(id))
}

const reducer = {
  tasks: tasks.reducer
}

export const store = configureStore({
  reducer,
  devTools: process.env.NODE_ENV !== 'production'
})
