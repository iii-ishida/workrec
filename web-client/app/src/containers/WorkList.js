import React, { useCallback } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import * as Actions from 'src/actions'

import { default as Child } from 'src/components/WorkList'

export default function WorkList() {
  const works = useSelector(state => state.works.get('works'))

  const dispatch = useDispatch()

  const fetchWorks = useCallback(
    () => dispatch(Actions.fetchWorks()),
    [dispatch]
  )
  const toggleState = useCallback(
    (id, currentState, time) => dispatch(Actions.toggleState(id, currentState, time)),
    [dispatch]
  )
  const finishWork = useCallback(
    (id, time) => dispatch(Actions.finishWork(id, time)),
    [dispatch]
  )
  const unfinishWork = useCallback(
    (id, time) => dispatch(Actions.unfinishWork(id, time)),
    [dispatch]
  )
  const deleteWork = useCallback(
    (id) => dispatch(Actions.deleteWork(id)),
    [dispatch]
  )

  return (
    <Child
      works={works}
      fetchWorks={fetchWorks}
      toggleState={toggleState}
      finishWork={finishWork}
      unfinishWork={unfinishWork}
      deleteWork={deleteWork}
    />
  )
}
