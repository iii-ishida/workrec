import firebase from 'firebase/app'
import { getAuth, createUserWithEmailAndPassword, signInAnonymously, onIdTokenChanged, connectAuthEmulator } from "firebase/auth";

const firebaseConfig = {}

firebase.initializeApp(firebaseConfig)
const auth = getAuth()

if (process.env.NODE_ENV === 'development') {
  connectAuthEmulator(auth, 'http://localhost:9099')
}

export async function signUpUserWithEmailAndPassword(email: string, password: string): Promise<void> {
  await createUserWithEmailAndPassword(auth, email, password);
}

export async function signUpAnonymously(): Promise<void> {
  await signInAnonymously(auth)
}

export function getIdToken(): Promise<string | null> {
  return new Promise((resolve) => {
    const unsubscribe = onIdTokenChanged(auth, async (user) => {
      unsubscribe()

      if (user) {
        resolve(await user.getIdToken())
      } else {
        resolve(null)
      }
    })
  })
}

import { redirect } from "@remix-run/node";

export async function requireSignIn(): Promise<void> {
  const idToken = await getIdToken()

  if (!idToken) {
    redirect('/signIn')
    return
  }
}