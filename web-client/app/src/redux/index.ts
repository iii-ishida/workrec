import { createSlice, configureStore } from '@reduxjs/toolkit'
import API, { TaskState } from 'src/api'

const user = createSlice({
  name: 'user',
  initialState: null,
  reducers: {
    signIn: (_, action) => action.payload.user,
    signOut: () => null,
  },
})

const tasks = createSlice({
  name: 'tasks',
  initialState: [],
  reducers: {
    recieveTasks: (_, action) => action.payload.tasks,
    deleteTask: (state, action) =>
      state.filter(task => task.id !== action.payload),
  },
})

export const fetchTasks = userIdToken => async dispatch => {
  const list = await new API(userIdToken).getTaskList()
  dispatch(tasks.actions.recieveTasks(list))
}

export const addTask = (userIdToken, title) => async dispatch => {
  await new API(userIdToken).addTask(title)
  dispatch(fetchTasks(userIdToken))
}

export const toggleState = (
  userIdToken,
  id,
  currentState,
  time
) => async dispatch => {
  const api = new API(userIdToken)
  const toggleAPI = {
    [TaskState.UNSTARTED]: api.startTask,
    [TaskState.STARTED]: api.pauseTask,
    [TaskState.PAUSED]: api.resumeTask,
    [TaskState.RESUMED]: api.pauseTask,
  }

  await toggleAPI[currentState](id, time)
  dispatch(fetchTasks(userIdToken))
}

export const finishTask = (userIdToken, id, time) => async dispatch => {
  await new API(userIdToken).finishTask(id, time)
  dispatch(fetchTasks(userIdToken))
}

export const unfinishTask = (userIdToken, id, time) => async dispatch => {
  await new API(userIdToken).unfinishTask(id, time)
  dispatch(fetchTasks(userIdToken))
}

export const deleteTask = (userIdToken, id) => async dispatch => {
  await new API(userIdToken).deleteTask(id)
  dispatch(tasks.actions.deleteTask(id))
}

const reducer = {
  tasks: tasks.reducer,
  user: user.reducer,
}

export const UserActions = user.actions

export const store = configureStore({
  reducer,
  devTools: process.env.NODE_ENV !== 'production',
})
