import { createSlice, configureStore, PayloadAction } from '@reduxjs/toolkit'

type User = {
  idToken: string
}

const user = createSlice({
  name: 'user',
  initialState: { idToken: '' },
  reducers: {
    signIn: (_, action: PayloadAction<User>) => action.payload,
    signOut: () => null,
  },
})

const reducer = {
  user: user.reducer,
}

export const UserActions = user.actions

export const store = configureStore({
  reducer,
  devTools: process.env.NODE_ENV !== 'production',
})
