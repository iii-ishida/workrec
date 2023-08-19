import { useLoaderData, useSubmit } from '@remix-run/react'
import { ActionArgs, LoaderArgs, json, redirect } from '@remix-run/node'
import { useCallback } from 'react'
import { commitSession, getSession } from '~/services/session.server'
import { checkSessionCookie, createSessionCookie, getRestConfig } from '~/services/auth.server'
import { signInWithEmailAndPassword } from '~/services/auth-client'

export async function loader({ request }: LoaderArgs) {
  const session = await getSession(request.headers.get('cookie'))
  const { uid } = await checkSessionCookie(session.get('session') || '')
  const headers = {
    'Set-Cookie': await commitSession(session),
  }
  if (uid) {
    return redirect('/', { headers })
  }

  const { apiKey, domain } = getRestConfig()
  return json({ apiKey, domain }, { headers })
}

export async function action({ request }: ActionArgs) {
  const form = await request.formData()
  const idToken = form.get('idToken')
  let sessionCookie
  try {
    if (typeof idToken === 'string') {
      sessionCookie = await createSessionCookie(idToken)
    } else {
      const email = form.get('email')
      const password = form.get('password')
      const formError = json(
        { error: 'Please fill all fields!' },
        { status: 400 }
      )
      if (typeof email !== 'string') return formError
      if (typeof password !== 'string') return formError

      const idToken = await signInWithEmailAndPassword(
        email,
        password,
        getRestConfig()
      )
      sessionCookie = await createSessionCookie(idToken)
    }

    const session = await getSession(request.headers.get('cookie'))
    session.set('session', sessionCookie)
    return redirect('/', {
      headers: {
        'Set-Cookie': await commitSession(session),
      },
    })
  } catch (error) {
    console.error(error)
    return json({ error: String(error) }, { status: 401 })
  }
}

export default function Component() {
  const restConfig = useLoaderData<typeof loader>()
  const submit = useSubmit()

  const handleSubmit = useCallback(
    async (event: React.FormEvent<HTMLFormElement>) => {
      event.preventDefault()
      // To avoid rate limiting, we sign in client side if we can.
      const idToken = await signInWithEmailAndPassword(
        event.currentTarget.email.value,
        event.currentTarget.password.value,
        restConfig
      )

      submit({ idToken }, { method: 'post' })
    },
    [submit, restConfig]
  )

  return (
    <div className="container m-10 mx-auto rounded-md border-2 border-gray-200 bg-gray-100 p-10">
      <h1 className="text-center text-subhead font-semibold">Sign In</h1>
      <form
        className="flex flex-col gap-8 p-10"
        method="post"
        onSubmit={handleSubmit}
      >
        <div className="flex flex-col">
          <label className="text-sm" htmlFor="email">
            Email
          </label>
          <input
            id="email"
            type="email"
            name="email"
            autoComplete="username"
            required
          />
        </div>
        <div className="flex flex-col">
          <label className="text-sm" htmlFor="password">
            Password
          </label>
          <input
            id="password"
            type="password"
            name="password"
            autoComplete="current-password"
            required
          />
        </div>
        <button className="btn-rounded btn-primary self-end">Sign In</button>
      </form>
    </div>
  )
}
