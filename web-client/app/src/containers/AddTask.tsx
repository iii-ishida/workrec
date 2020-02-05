import React, { useCallback } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { addTask as addTaskAction } from 'src/redux'

import { default as Child } from 'src/components/AddTask'

const AddTask: React.FC = () => {
  const userIdToken = useSelector(state => state.user?.idToken)

  const dispatch = useDispatch()

  const addTask = useCallback(
    (userIdToken, title) => dispatch(addTaskAction(userIdToken, title)),
    [dispatch]
  )

  return <Child userIdToken={userIdToken} addTask={addTask} />
}

export default AddTask
