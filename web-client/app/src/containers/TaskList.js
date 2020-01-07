import React, { useCallback } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import * as Actions from 'src/redux'

import { default as Child } from 'src/components/TaskList'

export default function TaskList() {
  const tasks = useSelector(state => state.tasks)

  const dispatch = useDispatch()

  const fetchTasks = useCallback(
    () => dispatch(Actions.fetchTasks()),
    [dispatch]
  )
  const toggleState = useCallback(
    (id, currentState, time) => dispatch(Actions.toggleState(id, currentState, time)),
    [dispatch]
  )
  const finishTask = useCallback(
    (id, time) => dispatch(Actions.finishTask(id, time)),
    [dispatch]
  )
  const unfinishTask = useCallback(
    (id, time) => dispatch(Actions.unfinishTask(id, time)),
    [dispatch]
  )
  const deleteTask = useCallback(
    (id) => dispatch(Actions.deleteTask(id)),
    [dispatch]
  )

  return (
    <Child
      tasks={tasks}
      fetchTasks={fetchTasks}
      toggleState={toggleState}
      finishTask={finishTask}
      unfinishTask={unfinishTask}
      deleteTask={deleteTask}
    />
  )
}
