import React from 'react'
import TaskList from 'src/containers/TaskList'
import AddTask from 'src/containers/AddTask'
import Login from 'src/components/Login'

const App: React.FC = () => (
  <div>
    <TaskList />
    <AddTask />
    <Login />
  </div>
)

export default App
