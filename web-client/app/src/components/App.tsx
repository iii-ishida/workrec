import React from 'react'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'
import PrivateRoute from 'src/containers/PrivateRoute'
import TaskListPage from 'src/containers/TaskListPage'
import Login from 'src/containers/Login'
import Loading from 'src/components/Loading'

type Props = {
  initialized: boolean
}
const App: React.FC<Props> = ({ initialized }: Props) =>
  initialized ? (
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
  ) : (
    <Loading />
  )

export default App
