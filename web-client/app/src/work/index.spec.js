import Immutable from 'immutable'
import { WorkState } from 'src/api'
import * as Work from './index.js'

describe('stateText', () => {
  it('state が UNSTARTED の場合は - を返すこと', () => {
    const work = Immutable.fromJS({state: WorkState.UNSTARTED})
    expect(Work.stateText(work)).toEqual('-')
  })

  it('state が STARTED の場合は 作業中 を返すこと', () => {
    const work = Immutable.fromJS({state: WorkState.STARTED})
    expect(Work.stateText(work)).toEqual('作業中')
  })

  it('state が PAUSED の場合は 停止中 を返すこと', () => {
    const work = Immutable.fromJS({state: WorkState.PAUSED})
    expect(Work.stateText(work)).toEqual('停止中')
  })

  it('state が RESUMED の場合は 作業中 を返すこと', () => {
    const work = Immutable.fromJS({state: WorkState.RESUMED})
    expect(Work.stateText(work)).toEqual('作業中')
  })

  it('state が FINISHED の場合は 完了 を返すこと', () => {
    const work = Immutable.fromJS({state: WorkState.FINISHED})
    expect(Work.stateText(work)).toEqual('完了')
  })
});

describe('startedAtText', () => {
  it('state が UNSTARTED の場合は - を返すこと', () => {
    const work = Immutable.fromJS({state: WorkState.UNSTARTED})
    expect(Work.startedAtText(work)).toEqual('-')
  })

  it('state が UNSTARTED でない場合は startedAt を yyyy-MM-dd HH:mm 形式にして返すこと', () => {
    const startedAt = new Date(2019, 0, 2, 3, 4)
    const work = Immutable.fromJS({state: WorkState.STARTED, startedAt: startedAt})
    expect(Work.startedAtText(work)).toEqual('2019-01-02 03:04')
  })
})

describe('workingTimeText', () => {
  it('state が UNSTARTED の場合は 0分 を返すこと', () => {
    const work = Immutable.fromJS({state: WorkState.UNSTARTED})
    expect(Work.workingTimeText(work)).toEqual('0分')
  })

  describe('state が UNSTARTED でない場合は算出した作業時間を返すこと', () => {
    it('作業時間が1日以上の場合は作業時間(日)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0)
      const pausedAt = new Date(2019, 1, 3, 11, 30)

      const work = Immutable.fromJS({state: WorkState.PAUSED, baseWorkingTime: baseWorkingTime, pausedAt: pausedAt})
      expect(Work.workingTimeText(work)).toEqual('1日1時間30分')
    })

    it('作業時間が1日未満の場合は作業時間(日)を表示しないこと', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0)
      const pausedAt = new Date(2019, 1, 3, 9, 59)

      const work = Immutable.fromJS({state: WorkState.PAUSED, baseWorkingTime: baseWorkingTime, pausedAt: pausedAt})
      expect(Work.workingTimeText(work)).toEqual('23時間59分')

    })

    it('作業時間が1時間以上の場合は作業時間(時)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0)
      const pausedAt = new Date(2019, 1, 3, 9, 59)

      const work = Immutable.fromJS({state: WorkState.PAUSED, baseWorkingTime: baseWorkingTime, pausedAt: pausedAt})
      expect(Work.workingTimeText(work)).toEqual('23時間59分')
    })

    it('作業時間が1日以上の場合は時間が0でも作業時間(時)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0)
      const pausedAt = new Date(2019, 1, 3, 10, 30)

      const work = Immutable.fromJS({state: WorkState.PAUSED, baseWorkingTime: baseWorkingTime, pausedAt: pausedAt})
      expect(Work.workingTimeText(work)).toEqual('1日0時間30分')
    })

    it('作業時間が1時間未満の場合は作業時間(時)を表示しないこと', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0)
      const pausedAt = new Date(2019, 1, 2, 10, 59)

      const work = Immutable.fromJS({state: WorkState.PAUSED, baseWorkingTime: baseWorkingTime, pausedAt: pausedAt})
      expect(Work.workingTimeText(work)).toEqual('59分')
    })

    it('作業時間が1分以上の場合は作業時間(分)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0)
      const pausedAt = new Date(2019, 1, 2, 10, 59)

      const work = Immutable.fromJS({state: WorkState.PAUSED, baseWorkingTime: baseWorkingTime, pausedAt: pausedAt})
      expect(Work.workingTimeText(work)).toEqual('59分')
    })

    it('作業時間が0分の場合でも作業時間(分)を表示すること', () => {
      const baseWorkingTime = new Date(2019, 1, 2, 10, 0)
      const pausedAt = new Date(2019, 1, 2, 10, 0)

      const work = Immutable.fromJS({state: WorkState.PAUSED, baseWorkingTime: baseWorkingTime, pausedAt: pausedAt})
      expect(Work.workingTimeText(work)).toEqual('0分')
    })
  })
})