import { ReactNode } from 'react'

export function SubmitButton({
  intent,
  children,
  className,
}: {
  intent: string
  children: ReactNode
  className?: string
}) {
  return (
    <button type="submit" className={className} name="intent" value={intent}>
      {children}
    </button>
  )
}
