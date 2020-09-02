import React, { useEffect, useState } from 'react'
import { ApolloProvider } from '@apollo/client'
import { newApolloClient } from 'src/workrec/apollo'
import { onAuthStateChanged } from 'src/workrec/auth'

type Props = {
  children: React.ReactNode
}

export const IdTokenContext = React.createContext(null)

export const WorkrecProvider: React.FC<Props> = ({ children }: Props) => {
  const [loaded, setLoaded] = useState(false)
  const [idToken, setIdToken] = useState('')
  const client = newApolloClient(idToken)

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(async (user) => {
      const idToken = (await user?.getIdToken()) ?? ''
      setIdToken(idToken)
      setLoaded(true)
    })

    return () => unsubscribe()
  })

  return (
    <IdTokenContext.Provider value={{ loaded, idToken }}>
      <ApolloProvider client={client}>{children}</ApolloProvider>
    </IdTokenContext.Provider>
  )
}
