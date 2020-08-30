import { useEffect, useState } from 'react'
import { useDispatch } from 'react-redux'
import { onAuthStateChanged } from 'src/auth'
import { UserActions } from 'src/redux'

export function useInitialized(): boolean {
  const dispatch = useDispatch()
  const [isInitialized, setInitialized] = useState(false)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(async (user) => {
      if (user) {
        const idToken = await user.getIdToken()
        dispatch(UserActions.signIn({ idToken }))
      } else {
        dispatch(UserActions.signOut())
      }
      setInitialized(true)
    })

    return () => unsubscribe()
  }, [dispatch])

  return isInitialized
}
