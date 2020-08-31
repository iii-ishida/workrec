import { useCallback, useEffect, useState } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { onAuthStateChanged } from 'src/workrec/auth'
import { UserActions } from 'src/workrec/redux'
import * as Actions from 'src/workrec/redux'
import { Task, State } from 'src/workrec'

export function useInitialized(): boolean {
  const dispatch = useDispatch()
  const [isInitialized, setInitialized] = useState(false)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(async (user) => {
      if (user) {
        const idToken = await user.getIdToken()
        dispatch(UserActions.signIn({ idToken }))
      } else {
        dispatch(UserActions.signOut())
      }
      setInitialized(true)
    })

    return () => unsubscribe()
  }, [dispatch])

  return isInitialized
}

export function useAuthIdToken(): string {
  return useSelector((state) => state.user?.idToken)
}

export function useTaskList(): Task[] {
  const dispatch = useDispatch()
  const idToken = useAuthIdToken()

  useEffect(() => {
    dispatch(Actions.fetchTasks(idToken))
  }, [dispatch, idToken])

  return useSelector((state) => state.tasks)
}

export function useAddTask(): (title: string) => void {
  const dispatch = useDispatch()
  const idToken = useAuthIdToken()

  return useCallback(
    (title: string) => dispatch(Actions.addTask(idToken, title)),
    [dispatch, idToken]
  )
}

export function useToggleTask(): (
  taskId: string,
  currentState: State,
  time: Date
) => void {
  const dispatch = useDispatch()
  const idToken = useAuthIdToken()

  return useCallback(
    (taskId: string, currentState: State, time: Date) =>
      dispatch(Actions.toggleState(idToken, taskId, currentState, time)),
    [dispatch, idToken]
  )
}

export function useFinishTask(): (taskId: string, time: Date) => void {
  const dispatch = useDispatch()
  const idToken = useAuthIdToken()

  return useCallback(
    (taskId: string, time: Date) =>
      dispatch(Actions.finishTask(idToken, taskId, time)),
    [dispatch, idToken]
  )
}

export function useUnfinishTask(): (taskId: string, time: Date) => void {
  const dispatch = useDispatch()
  const idToken = useAuthIdToken()

  return useCallback(
    (taskId: string, time: Date) =>
      dispatch(Actions.unfinishTask(idToken, taskId, time)),
    [dispatch, idToken]
  )
}

export function useDeleteTask(): (taskId: string) => void {
  const dispatch = useDispatch()
  const idToken = useAuthIdToken()

  return useCallback(
    (taskId: string) => dispatch(Actions.deleteTask(idToken, taskId)),
    [dispatch, idToken]
  )
}
