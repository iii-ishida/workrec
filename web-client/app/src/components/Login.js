import React from 'react'
import { loginWithGoogle } from 'src/auth'

const Login = () => (
  <div>
    <button onClick={() => loginWithGoogle()}>Login with Google</button>
  </div>
)

export default Login
