import { TaskState } from 'src/api'

export const stateText = task => {
  const state = task.get('state')

  switch (state) {
  case TaskState.UNSTARTED: return '-'
  case TaskState.STARTED:   return '作業中'
  case TaskState.PAUSED:    return '停止中'
  case TaskState.RESUMED:   return '作業中'
  case TaskState.FINISHED:  return '完了'
  default:
    return '-'
  }
}

export const startedAtText = task => {
  if (task.get('state') === TaskState.UNSTARTED) {
    return '-'
  }

  const startedAt = task.get('startedAt')

  const zeroPad = num => `0${num}`.slice(-2)

  const year   = startedAt.getFullYear()
  const month  = zeroPad(startedAt.getMonth()+1)
  const day    = zeroPad(startedAt.getDate())
  const hour   = zeroPad(startedAt.getHours())
  const minute = zeroPad(startedAt.getMinutes())

  return `${year}-${month}-${day} ${hour}:${minute}`
}

export const workingTimeText = task => {
  const workingTimeInMinute  = calcWorkingMinutes(task)
  const workingDay = Math.floor(workingTimeInMinute / 60 / 24)
  const workingHour = Math.floor((workingTimeInMinute % (60 * 24)) / 60)
  const workingMinute = Math.floor((workingTimeInMinute % (60 * 24) % 60))

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

const calcWorkingMinutes = task => {
  const state = task.get('state')
  if (state === TaskState.UNSTARTED) {
    return 0
  }

  const start = task.get('baseWorkingTime')
  const end = task.get('pausedAt') || new Date()

  return Math.floor((end.getTime() - start.getTime()) / 1000 / 60)
}
