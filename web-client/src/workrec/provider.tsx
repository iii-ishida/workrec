import React from 'react'
import { ApolloProvider } from '@apollo/client'
import { Provider } from 'react-redux'
import { newApolloClient } from 'src/workrec/apollo'
import { useAuthIdToken } from 'src/workrec/hooks'
import { store } from 'src/workrec/redux'

type Props = {
  children: React.ReactNode
}

export const WorkrecProvider: React.FC<Props> = ({ children }: Props) => {
  return (
    <Provider store={store}>
      <ChildWorkrecProvider>{children}</ChildWorkrecProvider>
    </Provider>
  )
}

const ChildWorkrecProvider: React.FC<Props> = ({ children }: Props) => {
  const idToken = useAuthIdToken()
  const client = newApolloClient(idToken)

  return (
    <Provider store={store}>
      <ApolloProvider client={client}>{children}</ApolloProvider>
    </Provider>
  )
}
