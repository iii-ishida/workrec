import React, { useCallback, useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import * as Actions from 'src/redux'
import { State } from 'src/task'

import { default as Child } from 'src/components/TaskListPage'

const TaskListPage: React.FC = () => {
  const userIdToken = useSelector(state => state.user?.idToken)
  const tasks = useSelector(state => state.tasks)

  const dispatch = useDispatch()

  useEffect(() => {
    dispatch(Actions.fetchTasks(userIdToken))
  }, [dispatch, userIdToken])

  const addTask = useCallback(
    (userIdToken, title) => dispatch(Actions.addTask(userIdToken, title)),
    [dispatch]
  )

  const toggleState = useCallback(
    (userIdToken: string, taskId: string, currentState: State, time: Date) =>
      dispatch(Actions.toggleState(userIdToken, taskId, currentState, time)),
    [dispatch]
  )

  const finishTask = useCallback(
    (userIdToken: string, taskId: string, time: Date) =>
      dispatch(Actions.finishTask(userIdToken, taskId, time)),
    [dispatch]
  )

  const unfinishTask = useCallback(
    (userIdToken: string, taskId: string, time: Date) =>
      dispatch(Actions.unfinishTask(userIdToken, taskId, time)),
    [dispatch]
  )

  const deleteTask = useCallback(
    (userIdToken: string, taskId: string) =>
      dispatch(Actions.deleteTask(userIdToken, taskId)),
    [dispatch]
  )

  return (
    <Child
      userIdToken={userIdToken}
      tasks={tasks}
      addTask={addTask}
      toggleState={toggleState}
      finishTask={finishTask}
      unfinishTask={unfinishTask}
      deleteTask={deleteTask}
    />
  )
}

export default TaskListPage
