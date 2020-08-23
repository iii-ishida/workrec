import React, { useEffect, useState } from 'react'
import { useDispatch } from 'react-redux'
import { Switch, Route } from 'react-router-dom'
import PrivateRoute from 'src/components/PrivateRoute'
import TaskListPage from 'src/components/TaskListPage'
import Login from 'src/components/Login'
import Loading from 'src/components/Loading'
import { onAuthStateChanged } from 'src/auth'
import { UserActions } from 'src/redux'

const AppContainer: React.FC = () => {
  const dispatch = useDispatch()

  const [initialized, setInitialized] = useState(false)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged((user) => {
      if (user) {
        user.getIdToken().then((idToken) => {
          dispatch(UserActions.signIn({ idToken }))
          setInitialized(true)
        })
      } else {
        dispatch(UserActions.signOut())
        setInitialized(true)
      }
    })

    return () => unsubscribe()
  })

  return <App initialized={initialized} />
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
