import React, { useCallback } from 'react'
import { useDispatch } from 'react-redux'
import { addWork as addWorkAction} from 'src/actions'
import { default as Child } from 'src/components/AddWork'

export default function AddWork() {
  const dispatch = useDispatch()

  const addWork = useCallback(
    (title) => dispatch(addWorkAction(title)),
    [dispatch]
  )

  return (
    <Child addWork={addWork} />
  )
}
