import React from 'react'
import { Redirect } from 'react-router-dom'
import { loginWithGoogle } from 'src/auth'

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

export default Login
