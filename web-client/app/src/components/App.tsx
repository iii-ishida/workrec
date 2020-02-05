import React from 'react'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'
import PrivateRoute from 'src/containers/PrivateRoute'
import TaskList from 'src/containers/TaskList'
import AddTask from 'src/containers/AddTask'
import Login from 'src/containers/Login'

const App: React.FC = () => (
  <Router>
    <Switch>
      <PrivateRoute exact path="/">
        <TaskList />
        <AddTask />
      </PrivateRoute>
      <Route path="/login">
        <Login />
      </Route>
    </Switch>
  </Router>
)

export default App
