import React, { useEffect, useState } from 'react'
import { useDispatch } from 'react-redux'
import { onAuthStateChanged } from 'src/auth'
import { UserActions } from 'src/redux'
import { default as Child } from 'src/components/App'

const App: React.FC = () => {
  const dispatch = useDispatch()

  const [initialized, setInitialized] = useState(false)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged((user) => {
      if (user) {
        user.getIdToken().then((idToken) => {
          dispatch(UserActions.signIn({ user: { idToken } }))
          setInitialized(true)
        })
      } else {
        dispatch(UserActions.signOut())
        setInitialized(true)
      }
    })

    return () => unsubscribe()
  })

  return <Child initialized={initialized} />
}

export default App
