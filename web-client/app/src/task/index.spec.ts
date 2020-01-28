import { TaskState } from 'src/api'
import * as Task from './index'

describe('stateText', () => {
  it('state が UNSTARTED の場合は - を返すこと', () => {
    const task = { state: TaskState.UNSTARTED }
    expect(Task.stateText(task)).toEqual('-')
  })

  it('state が STARTED の場合は 作業中 を返すこと', () => {
    const task = { state: TaskState.STARTED }
    expect(Task.stateText(task)).toEqual('作業中')
  })

  it('state が PAUSED の場合は 停止中 を返すこと', () => {
    const task = { state: TaskState.PAUSED }
    expect(Task.stateText(task)).toEqual('停止中')
  })

  it('state が RESUMED の場合は 作業中 を返すこと', () => {
    const task = { state: TaskState.RESUMED }
    expect(Task.stateText(task)).toEqual('作業中')
  })

  it('state が FINISHED の場合は 完了 を返すこと', () => {
    const task = { state: TaskState.FINISHED }
    expect(Task.stateText(task)).toEqual('完了')
  })
})

describe('startedAtText', () => {
  it('state が UNSTARTED の場合は - を返すこと', () => {
    const task = { state: TaskState.UNSTARTED }
    expect(Task.startedAtText(task)).toEqual('-')
  })

  it('state が UNSTARTED でない場合は startedAt を yyyy-MM-dd HH:mm 形式にして返すこと', () => {
    const startedAt = new Date(2019, 0, 2, 3, 4).toISOString()
    const task = { state: TaskState.STARTED, startedAt: startedAt }
    expect(Task.startedAtText(task)).toEqual('2019-01-02 03:04')
  })
})

describe('workingTimeText', () => {
  it('state が UNSTARTED の場合は 0分 を返すこと', () => {
    const task = { state: TaskState.UNSTARTED }
    expect(Task.workingTimeText(task)).toEqual('0分')
  })

  describe('state が UNSTARTED でない場合は算出した作業時間を返すこと', () => {
    it('作業時間が1日以上の場合は作業時間(日)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0).toISOString()
      const pausedAt = new Date(2019, 1, 3, 11, 30).toISOString()

      const task = {
        state: TaskState.PAUSED,
        baseWorkingTime: baseWorkingTime,
        pausedAt: pausedAt,
      }
      expect(Task.workingTimeText(task)).toEqual('1日1時間30分')
    })

    it('作業時間が1日未満の場合は作業時間(日)を表示しないこと', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0).toISOString()
      const pausedAt = new Date(2019, 1, 3, 9, 59).toISOString()

      const task = {
        state: TaskState.PAUSED,
        baseWorkingTime: baseWorkingTime,
        pausedAt: pausedAt,
      }
      expect(Task.workingTimeText(task)).toEqual('23時間59分')
    })

    it('作業時間が1時間以上の場合は作業時間(時)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0).toISOString()
      const pausedAt = new Date(2019, 1, 3, 9, 59).toISOString()

      const task = {
        state: TaskState.PAUSED,
        baseWorkingTime: baseWorkingTime,
        pausedAt: pausedAt,
      }
      expect(Task.workingTimeText(task)).toEqual('23時間59分')
    })

    it('作業時間が1日以上の場合は時間が0でも作業時間(時)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0).toISOString()
      const pausedAt = new Date(2019, 1, 3, 10, 30).toISOString()

      const task = {
        state: TaskState.PAUSED,
        baseWorkingTime: baseWorkingTime,
        pausedAt: pausedAt,
      }
      expect(Task.workingTimeText(task)).toEqual('1日0時間30分')
    })

    it('作業時間が1時間未満の場合は作業時間(時)を表示しないこと', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0).toISOString()
      const pausedAt = new Date(2019, 1, 2, 10, 59).toISOString()

      const task = {
        state: TaskState.PAUSED,
        baseWorkingTime: baseWorkingTime,
        pausedAt: pausedAt,
      }
      expect(Task.workingTimeText(task)).toEqual('59分')
    })

    it('作業時間が1分以上の場合は作業時間(分)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0).toISOString()
      const pausedAt = new Date(2019, 1, 2, 10, 59).toISOString()

      const task = {
        state: TaskState.PAUSED,
        baseWorkingTime: baseWorkingTime,
        pausedAt: pausedAt,
      }
      expect(Task.workingTimeText(task)).toEqual('59分')
    })

    it('作業時間が0分の場合でも作業時間(分)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0).toISOString()
      const pausedAt = new Date(2019, 1, 2, 10, 0).toISOString()

      const task = {
        state: TaskState.PAUSED,
        baseWorkingTime: baseWorkingTime,
        pausedAt: pausedAt,
      }
      expect(Task.workingTimeText(task)).toEqual('0分')
    })
  })
})
