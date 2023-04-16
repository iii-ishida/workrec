import { redirect } from "@remix-run/node";
import { Form, V2_MetaFunction } from "@remix-run/react";
import { signUpAnonymously } from "~/auth/authClient";

export const meta: V2_MetaFunction = () => {
  return [{ title: "Sign In" }];
};

export async function action() {
  await signUpAnonymously()
  return redirect('/')
}

export default function SignIn() {
  return (
    <div style={{ fontFamily: "system-ui, sans-serif", lineHeight: "1.4" }}>
      <h1>Welcome to Remix</h1>
      <Form method="post">
        <button type="submit">skip</button>
      </Form>
    </div>
  );
}
