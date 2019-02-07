import firebase from 'firebase/app'
import 'firebase/auth'
import { firebaseConfig } from 'src/firebase-config.js'

firebase.initializeApp(firebaseConfig);

export const loginWithGoogle = () => {
  const provider = new firebase.auth.GoogleAuthProvider();
  return firebase.auth().signInWithRedirect(provider)
}

export const getIdToken = () => {
  return new Promise(resolve => {
    const unsubscribe = firebase.auth().onAuthStateChanged(user => {
      unsubscribe()

      if (user) {
        resolve(user.getIdToken())
      } else {
        resolve(null)
      }
    })
  })
}
