import React from 'react'
import { loginWithGoogle } from '../auth'

const Login = () => (
  <div>
    <button onClick={() => loginWithGoogle()}>Login with Google</button>
  </div>
)

export default Login
