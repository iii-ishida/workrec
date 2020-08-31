import React from 'react'
import { Provider } from 'react-redux'
import { store } from 'src/redux'

type Props = {
  children: React.ReactNode
}

export const WorkrecProvider: React.FC<Props> = ({ children }: Props) => (
  <Provider store={store}>{children}</Provider>
)
