import React from 'react'
import { BrowserRouter as Router, Switch, Route, Redirect } from 'react-router-dom'
import TaskList from 'src/containers/TaskList'
import AddTask from 'src/containers/AddTask'
import Login from 'src/components/Login'

const App: React.FC = () => (
  <Router>
    <Switch>
      <Route exact path='/'>
        <TaskList />
        <AddTask />
      </Route>
      <Route exact path='/signin'>
        <Login />
      </Route>
    </Switch>
  </Router>
)

export default App
