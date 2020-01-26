import React, { useCallback } from 'react'
import { useDispatch } from 'react-redux'
import { addTask as addTaskAction} from 'src/redux'

import { default as Child } from 'src/components/AddTask'

const AddTask: React.FC = () => {
  const dispatch = useDispatch()

  const addTask = useCallback(
    (title) => dispatch(addTaskAction(title)),
    [dispatch]
  )

  return (
    <Child addTask={addTask} />
  )
}

export default AddTask
