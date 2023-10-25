import { Form, Link, useLoaderData } from '@remix-run/react'
import { useState, useEffect, ReactElement } from 'react'
import { TaskListItem, TaskState, taskListItemFromJson } from '~/api-client'
import { AddTaskForm } from '~/components/add-task-form'
import { SubmitButton } from '~/components/submit-button'

import type { loader } from './task-list.server'

// https://stackoverflow.com/a/33486055
function MD5(d: string) { let result = M(V(Y(X(d), 8 * d.length))); return result.toLowerCase() }; function M(d) { for (var _, m = "0123456789ABCDEF", f = "", r = 0; r < d.length; r++)_ = d.charCodeAt(r), f += m.charAt(_ >>> 4 & 15) + m.charAt(15 & _); return f } function X(d) { for (var _ = Array(d.length >> 2), m = 0; m < _.length; m++)_[m] = 0; for (m = 0; m < 8 * d.length; m += 8)_[m >> 5] |= (255 & d.charCodeAt(m / 8)) << m % 32; return _ } function V(d) { for (var _ = "", m = 0; m < 32 * d.length; m += 8)_ += String.fromCharCode(d[m >> 5] >>> m % 32 & 255); return _ } function Y(d, _) { d[_ >> 5] |= 128 << _ % 32, d[14 + (_ + 64 >>> 9 << 4)] = _; for (var m = 1732584193, f = -271733879, r = -1732584194, i = 271733878, n = 0; n < d.length; n += 16) { var h = m, t = f, g = r, e = i; f = md5_ii(f = md5_ii(f = md5_ii(f = md5_ii(f = md5_hh(f = md5_hh(f = md5_hh(f = md5_hh(f = md5_gg(f = md5_gg(f = md5_gg(f = md5_gg(f = md5_ff(f = md5_ff(f = md5_ff(f = md5_ff(f, r = md5_ff(r, i = md5_ff(i, m = md5_ff(m, f, r, i, d[n + 0], 7, -680876936), f, r, d[n + 1], 12, -389564586), m, f, d[n + 2], 17, 606105819), i, m, d[n + 3], 22, -1044525330), r = md5_ff(r, i = md5_ff(i, m = md5_ff(m, f, r, i, d[n + 4], 7, -176418897), f, r, d[n + 5], 12, 1200080426), m, f, d[n + 6], 17, -1473231341), i, m, d[n + 7], 22, -45705983), r = md5_ff(r, i = md5_ff(i, m = md5_ff(m, f, r, i, d[n + 8], 7, 1770035416), f, r, d[n + 9], 12, -1958414417), m, f, d[n + 10], 17, -42063), i, m, d[n + 11], 22, -1990404162), r = md5_ff(r, i = md5_ff(i, m = md5_ff(m, f, r, i, d[n + 12], 7, 1804603682), f, r, d[n + 13], 12, -40341101), m, f, d[n + 14], 17, -1502002290), i, m, d[n + 15], 22, 1236535329), r = md5_gg(r, i = md5_gg(i, m = md5_gg(m, f, r, i, d[n + 1], 5, -165796510), f, r, d[n + 6], 9, -1069501632), m, f, d[n + 11], 14, 643717713), i, m, d[n + 0], 20, -373897302), r = md5_gg(r, i = md5_gg(i, m = md5_gg(m, f, r, i, d[n + 5], 5, -701558691), f, r, d[n + 10], 9, 38016083), m, f, d[n + 15], 14, -660478335), i, m, d[n + 4], 20, -405537848), r = md5_gg(r, i = md5_gg(i, m = md5_gg(m, f, r, i, d[n + 9], 5, 568446438), f, r, d[n + 14], 9, -1019803690), m, f, d[n + 3], 14, -187363961), i, m, d[n + 8], 20, 1163531501), r = md5_gg(r, i = md5_gg(i, m = md5_gg(m, f, r, i, d[n + 13], 5, -1444681467), f, r, d[n + 2], 9, -51403784), m, f, d[n + 7], 14, 1735328473), i, m, d[n + 12], 20, -1926607734), r = md5_hh(r, i = md5_hh(i, m = md5_hh(m, f, r, i, d[n + 5], 4, -378558), f, r, d[n + 8], 11, -2022574463), m, f, d[n + 11], 16, 1839030562), i, m, d[n + 14], 23, -35309556), r = md5_hh(r, i = md5_hh(i, m = md5_hh(m, f, r, i, d[n + 1], 4, -1530992060), f, r, d[n + 4], 11, 1272893353), m, f, d[n + 7], 16, -155497632), i, m, d[n + 10], 23, -1094730640), r = md5_hh(r, i = md5_hh(i, m = md5_hh(m, f, r, i, d[n + 13], 4, 681279174), f, r, d[n + 0], 11, -358537222), m, f, d[n + 3], 16, -722521979), i, m, d[n + 6], 23, 76029189), r = md5_hh(r, i = md5_hh(i, m = md5_hh(m, f, r, i, d[n + 9], 4, -640364487), f, r, d[n + 12], 11, -421815835), m, f, d[n + 15], 16, 530742520), i, m, d[n + 2], 23, -995338651), r = md5_ii(r, i = md5_ii(i, m = md5_ii(m, f, r, i, d[n + 0], 6, -198630844), f, r, d[n + 7], 10, 1126891415), m, f, d[n + 14], 15, -1416354905), i, m, d[n + 5], 21, -57434055), r = md5_ii(r, i = md5_ii(i, m = md5_ii(m, f, r, i, d[n + 12], 6, 1700485571), f, r, d[n + 3], 10, -1894986606), m, f, d[n + 10], 15, -1051523), i, m, d[n + 1], 21, -2054922799), r = md5_ii(r, i = md5_ii(i, m = md5_ii(m, f, r, i, d[n + 8], 6, 1873313359), f, r, d[n + 15], 10, -30611744), m, f, d[n + 6], 15, -1560198380), i, m, d[n + 13], 21, 1309151649), r = md5_ii(r, i = md5_ii(i, m = md5_ii(m, f, r, i, d[n + 4], 6, -145523070), f, r, d[n + 11], 10, -1120210379), m, f, d[n + 2], 15, 718787259), i, m, d[n + 9], 21, -343485551), m = safe_add(m, h), f = safe_add(f, t), r = safe_add(r, g), i = safe_add(i, e) } return Array(m, f, r, i) } function md5_cmn(d, _, m, f, r, i) { return safe_add(bit_rol(safe_add(safe_add(_, d), safe_add(f, i)), r), m) } function md5_ff(d, _, m, f, r, i, n) { return md5_cmn(_ & m | ~_ & f, d, _, r, i, n) } function md5_gg(d, _, m, f, r, i, n) { return md5_cmn(_ & f | m & ~f, d, _, r, i, n) } function md5_hh(d, _, m, f, r, i, n) { return md5_cmn(_ ^ m ^ f, d, _, r, i, n) } function md5_ii(d, _, m, f, r, i, n) { return md5_cmn(m ^ (_ | ~f), d, _, r, i, n) } function safe_add(d, _) { var m = (65535 & d) + (65535 & _); return (d >> 16) + (_ >> 16) + (m >> 16) << 16 | 65535 & m } function bit_rol(d, _) { return d << _ | d >>> 32 - _ }

export default function Component() {
  const models = useLoaderData<typeof loader>()

  return (
    <div className="container flex flex-col gap-4">
      <TaskList models={models.map(taskListItemFromJson)} />
      <AddTaskForm intent="create" />
    </div>
  )
}

function TaskList({ models }: { models: TaskListItem[] }) {
  const [now, setNow] = useState<Date>(new Date(0))
  useEffect(() => {
    if (models.length > 0) {
      setNow(new Date())
    }
  }, [models])

  return (
    <div className="flex flex-col rounded-2  justify-center bg-gray-100">
      <SearchInput className="m-3" />
      <ul>
        {models.map((model) => (
          <li key={model.id} className='mx-2 border-b last:border-b-0 border-b-gray-300'>
            <TaskListRow model={model} now={now} />
          </li>
        ))}
      </ul>
    </div>
  )
}

function SearchInput({ className }: { className?: string }) {
  return (
    <div
      className={`${className} flex h-[44px] items-center rounded-1  border border-gray-400 bg-gray-200 stroke-primary-700 focus-within:border-primary-300 focus-within:stroke-primary-300`}
    >
      <svg
        width="21"
        height="21"
        viewBox="0 0 21 21"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="ml-2"
      >
        <circle
          cx="9"
          cy="8.99997"
          r="8"
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        <path
          d="M14.5 14.9579L19.5 19.958"
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>

      <input
        type="text"
        aria-label="search text"
        className="h-full border-none bg-transparent fill-none focus:outline-none"
      />
    </div>
  )
}

function TaskListRow({ model, now }: { model: TaskListItem; now: Date }) {
  return (
    <div className="flex items-end px-2 py-4">
      <Link className="grow" to={`/tasks/${model.id}`}>
        <TaskListRowContent model={model} now={now} />
      </Link>
      <Form method="post" className="ml-8">
        <input type="hidden" name="id" value={model.id} />
        <input type="hidden" name="state" value={model.state} />
        <SubmitButton intent="toggle">
          <ToggleButton state={model.state} />
        </SubmitButton>
      </Form>
      <div className="flex flex-col self-start">
        <MoreOptionButton />
      </div>
    </div>
  )
}

function TaskListRowContent({
  model,
  now,
}: {
  model: TaskListItem
  now: Date
}) {
  return (
    <div className="flex flex-row items-center justify-between">
      <div className="flex flex-col items-start gap-2">
        <div className="flex flex-row">
          <p>
            <StatusBadge state={model.state} />
          </p>
          <p className="ml-2 grow font-bold">{model.title}</p>
        </div>
        <p className="flex items-center fill-gray-500 text-right text-xs text-gray-700">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            height="24"
            viewBox="0 -960 960 960"
            width="24"
          >
            <path d="m612-292 56-56-148-148v-184h-80v216l172 172ZM480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-400Zm0 320q133 0 226.5-93.5T800-480q0-133-93.5-226.5T480-800q-133 0-226.5 93.5T160-480q0 133 93.5 226.5T480-160Z" />
          </svg>
          {totalWorkingTimeText(model, now)}
        </p>
      </div>
      <img
        className="clip-circle w-6"
        src={`https://gravatar.com/avatar/${MD5('test@example.com')}`}
        alt="User avatar"
      />
    </div>
  )
}

function MoreOptionButton() {
  return (
    <button type="button" aria-label="More options" className="p-2">
      <svg
        width="17"
        height="4"
        viewBox="0 0 17 4"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        className="fill-primary-700"
      >
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M2.99959 0C1.89297 0 0.997589 0.895379 0.997589 2.0004C0.997589 3.08622 1.86416 3.97119 2.94598 4H3.0532C4.13342 3.97119 4.99999 3.08622 4.99999 2.0004C4.99999 0.895379 4.10381 0 2.99959 0Z"
        />
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M8.99998 0C7.89438 0 6.99998 0.8952 6.99998 2C6.99998 3.0856 7.86558 3.9704 8.94638 3.9992H9.05358C10.1344 3.9704 11 3.0856 11 2C11 0.8952 10.1056 0 8.99998 0Z"
        />
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M14.9988 0C13.8946 0 13 0.894663 13 1.9988C13 3.08375 13.8659 3.96802 14.9452 3.9968H15.0524C16.1333 3.96802 17 3.08375 17 1.9988C17 0.894663 16.1037 0 14.9988 0Z"
        />
      </svg>
    </button>
  )
}

function StatusBadge({ state }: { state: TaskState }) {
  if (state === 'not_started' || state === 'paused') {
    return null
  }

  function text(state: TaskState): string {
    switch (state) {
      case 'in_progress':
        return '作業中'
      case 'completed':
        return '完了'
      default:
        return ''
    }
  }
  function bgColor(state: TaskState): string {
    switch (state) {
      case 'in_progress':
        return 'bg-primary-500'
      case 'completed':
        return 'bg-primary-200'
      default:
        return ''
    }
  }

  function textColor(state: TaskState): string {
    switch (state) {
      case 'in_progress':
        return 'text-gray-200'
      case 'completed':
        return 'text-primary-700'
      default:
        return ''
    }
  }

  return (
    <div
      className={`w-[44px] rounded-1 text-center font-bold ${bgColor(
        state
      )} p-1 text-xs ${textColor(state)}`}
    >
      {text(state)}
    </div>
  )
}

function ToggleButton({ state }: { state: TaskState }) {
  if (state === 'completed') {
    return null
  }

  function icon(state: TaskState): ReactElement {
    if (state === 'in_progress') {
      return (
        <svg
          width="10"
          height="10"
          viewBox="0 0 10 10"
          xmlns="http://www.w3.org/2000/svg"
        >
          <rect width="10" height="10" rx="2" />
        </svg>
      )
    } else {
      return (
        <svg
          width="11"
          height="12"
          viewBox="0 0 11 12"
          xmlns="http://www.w3.org/2000/svg"
          className="ml-[1px]"
        >
          <path d="M9.99759 4.26795C11.3309 5.03775 11.3309 6.96225 9.99759 7.73205L3.99759 11.1962C2.66425 11.966 0.997589 11.0037 0.997589 9.4641L0.997589 2.5359C0.997589 0.996296 2.66426 0.0340469 3.99759 0.803847L9.99759 4.26795Z" />
        </svg>
      )
    }
  }
  return (
    <div className="flex h-[28px] w-[44px] items-center justify-center rounded-1 border border-primary-300 fill-primary-300 hover:bg-primary-100">
      {icon(state)}
    </div>
  )
}

function totalWorkingTimeText(task: TaskListItem, now: Date): string {
  if (now.getTime() === 0) {
    return ''
  }

  const currentWorkingTime =
    task.state !== 'in_progress'
      ? 0
      : (now.getTime() - task.lastStartTime.getTime()) / 1000
  const workingTime = task.totalWorkingTime + currentWorkingTime
  const hour = Math.floor(workingTime / 3600)
  const minutes = Math.floor(((workingTime - hour * 3600) % 3600) / 60)
  if (hour > 0) {
    return `${hour}時間${minutes}分`
  } else {
    return `${minutes}分`
  }
}
