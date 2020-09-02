import { useCallback, useContext, useMemo } from 'react'
import { IdTokenContext } from 'src/workrec/provider'
import { Task, State } from 'src/workrec'
import {
  GET_TASK_LIST,
  ADD_TASK,
  START_TASK,
  PAUSE_TASK,
  RESUME_TASK,
  FINISH_TASK,
  UNFINISH_TASK,
  DELETE_TASK,
} from 'src/workrec/apollo'

import { useQuery, useMutation } from '@apollo/client'

const mutationOptions = { refetchQueries: [{ query: GET_TASK_LIST }] }

export function useInitialized(): boolean {
  const { loaded } = useContext(IdTokenContext)
  return loaded
}

export function useAuthIdToken(): string {
  const { idToken } = useContext(IdTokenContext)
  return idToken
}

export function useTaskList(): Task[] {
  const { data } = useQuery(GET_TASK_LIST, { partialRefetch: true })

  return useMemo(() => {
    return data?.tasks.edges.map((edge) => edge.node) ?? []
  }, [data])
}

export function useAddTask(): (title: string) => void {
  const [addTask] = useMutation(ADD_TASK, mutationOptions)

  return useCallback((title: string) => addTask({ variables: { title } }), [
    addTask,
  ])
}

export function useToggleTask(): (
  taskId: string,
  currentState: State,
  time: Date
) => void {
  const [startTask] = useMutation(START_TASK, mutationOptions)
  const [pauseTask] = useMutation(PAUSE_TASK, mutationOptions)
  const [resumeTask] = useMutation(RESUME_TASK, mutationOptions)

  return useCallback(
    (id: string, currentState: State, time: Date) => {
      const variables = { variables: { id, time } }
      switch (currentState) {
        case 'UNSTARTED':
          return startTask(variables)
        case 'STARTED':
          return pauseTask(variables)
        case 'PAUSED':
          return resumeTask(variables)
        case 'RESUMED':
          return pauseTask(variables)
      }
    },
    [startTask, pauseTask, resumeTask]
  )
}

export function useFinishTask(): (taskId: string, time: Date) => void {
  const [finishTask] = useMutation(FINISH_TASK, mutationOptions)

  return useCallback(
    (id: string, time: Date) => finishTask({ variables: { id, time } }),
    [finishTask]
  )
}

export function useUnfinishTask(): (taskId: string, time: Date) => void {
  const [unfinishTask] = useMutation(UNFINISH_TASK, mutationOptions)

  return useCallback(
    (id: string, time: Date) => unfinishTask({ variables: { id, time } }),
    [unfinishTask]
  )
}

export function useDeleteTask(): (taskId: string) => void {
  const [deleteTask] = useMutation(DELETE_TASK, mutationOptions)

  return useCallback((id: string) => deleteTask({ variables: { id } }), [
    deleteTask,
  ])
}
