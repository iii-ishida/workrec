import React from 'react'
import { Redirect } from 'react-router-dom'
import { loginWithGoogle } from 'src/workrec/auth'
import { useAuthIdToken } from 'src/workrec/hooks'

type Props = {
  isLoggedIn: boolean
}

const Login: React.FC<Props> = ({ isLoggedIn }: Props) =>
  isLoggedIn ? (
    <Redirect to="/" />
  ) : (
    <div>
      <button onClick={() => loginWithGoogle()}>Login with Google</button>
    </div>
  )

const LoginContainer: React.FC = () => {
  const idToken = useAuthIdToken()

  return <Login isLoggedIn={!!idToken} />
}

export default LoginContainer
