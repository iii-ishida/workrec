import { FirebaseRestConfig } from "./auth.server";

export const signInWithEmailAndPassword = async (email: string, password: string, { domain, apiKey }: FirebaseRestConfig) => {
  return await fetch(`${domain}/v1/accounts:signInWithPassword?key=${apiKey}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email,
      password,
      returnSecureToken: true,
    }),
  }).then((res) => res.json())
    .then((data) => data.idToken)
};