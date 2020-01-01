import React, { useCallback } from 'react'
import { useDispatch } from 'react-redux'
import { addTask as addTaskAction} from 'src/actions'
import { default as Child } from 'src/components/AddTask'

export default function AddTask() {
  const dispatch = useDispatch()

  const addTask = useCallback(
    (title) => dispatch(addTaskAction(title)),
    [dispatch]
  )

  return (
    <Child addTask={addTask} />
  )
}
