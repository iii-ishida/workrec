import React, { useEffect } from 'react'
import { useDispatch } from 'react-redux'
import { onAuthStateChanged } from 'src/auth'
import { UserActions } from 'src/redux'
import { default as Child } from 'src/components/App'

const App: React.FC = () => {
  const dispatch = useDispatch()

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(user => {
      if (user) {
        user.getIdToken().then(idToken => {
          dispatch(UserActions.signIn({ user: { idToken } }))
        })
      } else {
        dispatch(UserActions.signOut())
      }
    })

    return () => unsubscribe()
  })

  return <Child />
}

export default App
