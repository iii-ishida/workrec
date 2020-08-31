import React from 'react'
import TaskList from './TaskList'
import AddTask from './AddTask'
import { Task, State } from 'src/workrec'
import {
  useTaskList,
  useAddTask,
  useToggleTask,
  useFinishTask,
  useUnfinishTask,
  useDeleteTask,
} from 'src/workrec/hooks'

const TaskListPageContainer: React.FC = () => {
  const tasks = useTaskList()
  const addTask = useAddTask()
  const toggleState = useToggleTask()
  const finishTask = useFinishTask()
  const unfinishTask = useUnfinishTask()
  const deleteTask = useDeleteTask()

  return (
    <TaskListPage
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
  tasks: Task[]
  addTask: (title: string) => void
  toggleState: (taskId: string, state: State, time: Date) => void
  finishTask: (taskId: string, time: Date) => void
  unfinishTask: (taskId: string, time: Date) => void
  deleteTask: (taskId: string) => void
}

const TaskListPage: React.FC<Props> = ({
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
        tasks={tasks}
        toggleState={toggleState}
        finishTask={finishTask}
        unfinishTask={unfinishTask}
        deleteTask={deleteTask}
      />

      <AddTask addTask={addTask} />
    </div>
  )
}

export default TaskListPageContainer
