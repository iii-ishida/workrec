import { getApp, initializeApp } from 'firebase/app'
import { getAuth, createUserWithEmailAndPassword, signInAnonymously, onIdTokenChanged, connectAuthEmulator } from "firebase/auth";

const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.FIREBASE_DATABASE_URL,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
}

try {
  // check if firebase is already initialized
  getApp()
} catch {
  initializeApp(firebaseConfig)

  if (process.env.NODE_ENV === 'development') {
    const auth = getAuth()
    connectAuthEmulator(auth, 'http://localhost:9099')
  }
}

const auth = getAuth()

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

// Path: web-client/app/auth/requireSignIn.ts

import { redirect } from "@remix-run/node";

export async function requireSignIn(): Promise<void> {
  const idToken = await getIdToken()

  if (!idToken) {
    throw redirect('/signIn')
  }
}