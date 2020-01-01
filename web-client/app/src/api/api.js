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
  static getTaskList() {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/tasks`)
      .then(res => res.json())
      .then(json => this.taskListJsonToObject(json))
  }

  static addTask(title) {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/tasks`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({title: title})
    })
  }

  static startTask(id, time) {
    return this._changeTaskState('start', id, time)
  }

  static pauseTask(id, time) {
    return this._changeTaskState('pause', id, time)
  }

  static resumeTask(id, time) {
    return this._changeTaskState('resume', id, time)
  }

  static finishTask(id, time) {
    return this._changeTaskState('finish', id, time)
  }

  static unfinishTask(id, time) {
    return this._changeTaskState('unfinish', id, time)
  }

  static _changeTaskState(method, id, time) {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/tasks/${id}/${method}`, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({time: time.toISOString()})
    })
  }

  static deleteTask(id) {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/tasks/${id}`, {
      method: 'DELETE'
    })
  }

  static taskListJsonToObject(json) {
    const toDate = (t) => {
      if (!t) {
        return null
      }
      return new Date(t)
    }

    const tasks = (json.tasks || []).map(task => ({
      id: task.id,
      title: task.title,
      state: task.state,
      baseWorkingTime: toDate(task.base_working_time),
      startedAt: toDate(task.started_at),
      pausedAt: toDate(task.paused_at),
      createdAt: toDate(task.created_at),
      updatedAt: toDate(task.updated_at),
    }))

    return {
      tasks: tasks,
      nextPageToken: json.nextPageToken
    }
  }
}
