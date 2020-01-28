export type State = 'UNSTARTED' | 'STARTED' | 'PAUSED' | 'RESUMED' | 'FINISHED'

export interface Task {
  id: string
  title: string
  state: State
  baseWorkingTime: Date
  startedAt: Date
  pausedAt: Date
  createdAt: Date
  updatedAt: Date
}

export const stateText = task => {
  switch (task.state) {
    case 'UNSTARTED':
      return '-'
    case 'STARTED':
      return '作業中'
    case 'PAUSED':
      return '停止中'
    case 'RESUMED':
      return '作業中'
    case 'FINISHED':
      return '完了'
    default:
      return '-'
  }
}

export const startedAtText = task => {
  if (task.state === 'UNSTARTED') {
    return '-'
  }

  const startedAt = new Date(task.startedAt)

  const zeroPad = num => `0${num}`.slice(-2)

  const year = startedAt.getFullYear()
  const month = zeroPad(startedAt.getMonth() + 1)
  const day = zeroPad(startedAt.getDate())
  const hour = zeroPad(startedAt.getHours())
  const minute = zeroPad(startedAt.getMinutes())

  return `${year}-${month}-${day} ${hour}:${minute}`
}

export const workingTimeText = task => {
  const workingTimeInMinute = calcWorkingMinutes(task)
  const workingDay = Math.floor(workingTimeInMinute / 60 / 24)
  const workingHour = Math.floor((workingTimeInMinute % (60 * 24)) / 60)
  const workingMinute = Math.floor((workingTimeInMinute % (60 * 24)) % 60)

  let workingTimeText = ''
  if (workingDay !== 0) {
    workingTimeText += `${workingDay}日`
  }
  if (workingDay !== 0 || workingHour !== 0) {
    workingTimeText += `${workingHour}時間`
  }

  workingTimeText += `${workingMinute}分`

  return workingTimeText
}

function calcWorkingMinutes(task: Task): number {
  if (task.state === 'UNSTARTED') {
    return 0
  }

  const start = new Date(task.baseWorkingTime)
  const end = task.pausedAt ? new Date(task.pausedAt) : new Date()

  return Math.floor((end.getTime() - start.getTime()) / 1000 / 60)
}
