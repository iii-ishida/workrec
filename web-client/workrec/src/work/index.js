import { WorkState } from '../api'

const zeroPad = num => {
  return `0${num}`.slice(-2)
}

const isWorking = state => {
  return state === WorkState.STARTED || state === WorkState.RESUMED
}

export const stateText = work => {
  const state = work.get('state')

  switch (state) {
  case WorkState.UNSTARTED: return '-'
  case WorkState.STARTED:   return '作業中'
  case WorkState.PAUSED:    return '停止中'
  case WorkState.RESUMED:   return '作業中'
  case WorkState.FINISHED:  return '完了'
  default:
    return '-'
  }
}

export const startedAtText = work => {
  if (work.get('state') === WorkState.UNSTARTED) {
    return '-'
  }

  const startedAt = work.get('startedAt')

  const year   = startedAt.getFullYear()
  const month  = zeroPad(startedAt.getMonth()+1)
  const day    = zeroPad(startedAt.getDate())
  const hour   = zeroPad(startedAt.getHours())
  const minute = zeroPad(startedAt.getMinutes())

  return `${year}-${month}-${day} ${hour}:${minute}`
}

export const workingTimeText = work => {
  const state = work.get('state')

  if (state === WorkState.UNSTARTED) {
    return '0分'
  }

  const pausedAt = work.get('pausedAt')
  const baseWorkingTime = work.get('baseWorkingTime')

  let baseTime
  if (isWorking(state)) {
    baseTime = new Date()
  } else {
    baseTime = pausedAt
  }

  const workingTimeInMinute = Math.floor((baseTime.getTime() - baseWorkingTime.getTime()) / 1000 / 60)

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

