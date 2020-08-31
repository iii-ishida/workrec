import React from 'react'
import { Switch, Route } from 'react-router-dom'
import PrivateRoute from 'src/components/PrivateRoute'
import TaskListPage from 'src/components/TaskListPage'
import Login from 'src/components/Login'
import Loading from 'src/components/Loading'
import { useInitialized } from 'src/workrec//hooks'

const AppContainer: React.FC = () => {
  const isInitialized = useInitialized()

  return <App initialized={isInitialized} />
}

type Props = {
  initialized: boolean
}

const App: React.FC<Props> = ({ initialized }: Props) =>
  initialized ? (
    <Switch>
      <PrivateRoute exact path="/">
        <TaskListPage />
      </PrivateRoute>
      <Route path="/login">
        <Login />
      </Route>
    </Switch>
  ) : (
    <Loading />
  )

export default AppContainer
