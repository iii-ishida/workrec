import { V2_MetaFunction } from '@remix-run/react'
export {
  default,
  action,
  loader,
} from '~/route-containers/sign-in/sign-in.component'

export const meta: V2_MetaFunction = () => {
  return [{ title: 'Sign In' }]
}