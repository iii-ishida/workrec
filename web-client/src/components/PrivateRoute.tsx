import React from 'react'
import { Route, Redirect, RouteProps } from 'react-router-dom'
import { useAuthIdToken } from 'src/workrec/hooks'

const PrivateRoute: React.FC<RouteProps> = ({
  children,
  ...rest
}: RouteProps) => {
  const idToken = useAuthIdToken()

  return (
    <Route
      {...rest}
      render={({ location }) =>
        idToken ? (
          children
        ) : (
          <Redirect
            to={{
              pathname: '/login',
              state: { from: location },
            }}
          />
        )
      }
    />
  )
}

export default PrivateRoute
