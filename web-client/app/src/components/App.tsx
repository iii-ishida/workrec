import React from 'react'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'
import PrivateRoute from 'src/containers/PrivateRoute'
import TaskListPage from 'src/containers/TaskListPage'
import Login from 'src/containers/Login'

const App: React.FC = () => (
  <Router>
    <Switch>
      <PrivateRoute exact path="/">
        <TaskListPage />
      </PrivateRoute>
      <Route path="/login">
        <Login />
      </Route>
    </Switch>
  </Router>
)

export default App
