import firebase from 'firebase/app'
import 'firebase/auth'
import { firebaseConfig } from 'src/firebase-config'

firebase.initializeApp(firebaseConfig)

export function loginWithGoogle(): Promise<void> {
  const provider = new firebase.auth.GoogleAuthProvider()
  return firebase.auth().signInWithRedirect(provider)
}

export function getIdToken(): Promise<string | null> {
  return new Promise((resolve) => {
    const unsubscribe = firebase.auth().onAuthStateChanged((user) => {
      unsubscribe()

      if (user) {
        resolve(user.getIdToken())
      } else {
        resolve(null)
      }
    })
  })
}

export function onAuthStateChanged(callback): firebase.Unsubscribe {
  return firebase.auth().onAuthStateChanged((user) => {
    callback(user)
  })
}
