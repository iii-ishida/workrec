import type { Session } from "@remix-run/node";
import { redirect } from "@remix-run/node";
import { getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { destroySession, getSession } from "~/services/session.server";
import { signInWithEmailAndPassword } from "./auth-client";

export interface FirebaseRestConfig {
  apiKey: string;
  domain: string;
}

if (getApps().length === 0) {
  let config = undefined;
  if (process.env.NODE_ENV === "development") {
    console.warn(
      "Missing SERVICE_ACCOUNT environment variable, using local emulator"
    );
    // https://github.com/firebase/firebase-admin-node/issues/776
    process.env.FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099";
    config = {
      projectId: "demo-test",
    };
  }
  initializeApp(config);
}

const auth = getAuth();

// Warning: though getRestConfig is only run server side, its return value may be sent to the client
export const getRestConfig = () => {
  if (process.env.NODE_ENV === "development" && !process.env.API_KEY) {
    return {
      apiKey: "fake-api-key",
      domain: "http://localhost:9099/identitytoolkit.googleapis.com",
    };
  } else if (!process.env.API_KEY) {
    throw new Error("Missing API_KEY environment variable");
  } else {
    return {
      apiKey: process.env.API_KEY,
      domain: "https://identitytoolkit.googleapis.com",
    };
  }
}

export const checkSessionCookie = async (session: Session) => {
  try {
    const decodedIdToken = await auth.verifySessionCookie(
      session.get("session") || ""
    );
    return decodedIdToken;
  } catch {
    return { uid: undefined };
  }
};

export const requireAuth = async (request: Request): Promise<string> => {
  const session = await getSession(request.headers.get("cookie"));
  const { uid } = await checkSessionCookie(session);
  if (!uid) {
    throw redirect("/sign-in", {
      headers: { "Set-Cookie": await destroySession(session) },
    });
  }
  return session.get("session");
};

export const createSessionCookie = async (idToken: string) => {
  const expiresIn = 1000 * 60 * 60 * 24 * 7; // 1 week
  const sessionCookie = await auth.createSessionCookie(idToken, { expiresIn });
  return sessionCookie;
};

export const signUpWithEmailAndPassword = async (email: string, password: string, config: FirebaseRestConfig) => {
  await auth.createUser({ email, password });

  const idToken = await signInWithEmailAndPassword(email, password, config);
  return await createSessionCookie(idToken);
};

export const signUpAnonymously = async ({ domain, apiKey }: FirebaseRestConfig) => {
  return await fetch(`${domain}/v1/accounts:signUp?key=${apiKey}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
  }).then((res) => res.json())
    .then((data) => data.idToken)
}


