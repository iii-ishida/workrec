import React from 'react'
import { useSelector } from 'react-redux'
import { default as Child } from 'src/components/Login'

const Login: React.FC = () => {
  const user = useSelector((state) => state.user)

  return <Child isLoggedIn={!!user} />
}

export default Login
