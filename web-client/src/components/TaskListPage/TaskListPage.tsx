import React, { useCallback, useEffect } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import TaskList from './TaskList'
import AddTask from './AddTask'
import * as Actions from 'src/redux'
import { Task, State } from 'src/workrec'

const TaskListPageContainer: React.FC = () => {
  const userIdToken = useSelector((state) => state.user?.idToken)
  const tasks = useSelector((state) => state.tasks)

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
    <TaskListPage
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

type Props = {
  userIdToken: string
  tasks: Task[]
  addTask: (userIdToken: string, title: string) => void
  toggleState: (
    userIdToken: string,
    taskId: string,
    state: State,
    time: Date
  ) => void
  finishTask: (userIdToken: string, taskId: string, time: Date) => void
  unfinishTask: (userIdToken: string, taskId: string, time: Date) => void
  deleteTask: (userIdToken: string, taskId: string) => void
}

const TaskListPage: React.FC<Props> = ({
  userIdToken,
  tasks,
  addTask,
  toggleState,
  finishTask,
  unfinishTask,
  deleteTask,
}: Props) => {
  return (
    <div>
      <TaskList
        userIdToken={userIdToken}
        tasks={tasks}
        toggleState={toggleState}
        finishTask={finishTask}
        unfinishTask={unfinishTask}
        deleteTask={deleteTask}
      />

      <AddTask userIdToken={userIdToken} addTask={addTask} />
    </div>
  )
}

export default TaskListPageContainer
