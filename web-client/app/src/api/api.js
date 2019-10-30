import { getIdToken } from 'src/auth'

const fetchRequest = (url, req = {}) => {
  return getIdToken().then(idToken => {
    if (idToken) {
      req.headers = {...req.headers,  ...{'Authorization': 'Bearer ' + idToken}}
    }

    return fetch(url, req)
  })
}

export default class API {
  static getWorkList() {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works`)
      .then(res => res.json())
      .then(json => this.worklistJsonToObject(json))
  }

  static addWork(title) {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({title: title})
    })
  }

  static startWork(id, time) {
    return this._changeWorkState('start', id, time)
  }

  static pauseWork(id, time) {
    return this._changeWorkState('pause', id, time)
  }

  static resumeWork(id, time) {
    return this._changeWorkState('resume', id, time)
  }

  static finishWork(id, time) {
    return this._changeWorkState('finish', id, time)
  }

  static unfinishWork(id, time) {
    return this._changeWorkState('unfinish', id, time)
  }

  static _changeWorkState(method, id, time) {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works/${id}/${method}`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({time: time.toISOString()})
    })
  }

  static deleteWork(id) {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works/${id}`, {
      method: 'DELETE'
    })
  }

  static worklistJsonToObject(json) {
    const toDate = (t) => {
      if (!t) {
        return null
      }
      return new Date(t)
    }

    const works = (json.works || []).map(work => ({
      id: work.id,
      title: work.title,
      state: work.state,
      baseWorkingTime: toDate(work.base_working_time),
      startedAt: toDate(work.started_at),
      pausedAt: toDate(work.paused_at),
      createdAt: toDate(work.created_at),
      updatedAt: toDate(work.updated_at),
    }))

    return {
      works: works,
      nextPageToken: json.nextPageToken
    }
  }
}
