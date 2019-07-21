import React from 'react'
import { loginWithGoogle } from 'src/auth'

export default function Login() {
  return (
    <div>
      <button onClick={() => loginWithGoogle()}>Login with Google</button>
    </div>
  )
}

