import React from 'react'
import { useSelector } from 'react-redux'
import { Redirect } from 'react-router-dom'
import { loginWithGoogle } from 'src/workrec/auth'

const LoginContainer: React.FC = () => {
  const user = useSelector((state) => state.user)

  return <Login isLoggedIn={!!user} />
}

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

export default LoginContainer
