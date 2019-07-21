import { getIdToken } from 'src/auth';
const worklist_pb = require('./pb/worklist_pb');
const command_request_pb = require('./pb/command_request_pb');
const google_protobuf_timestamp_pb = require('google-protobuf/google/protobuf/timestamp_pb.js');

const fetchRequest = (url, req = {}) => {
  return getIdToken().then(idToken => {
    if (idToken) {
      req.headers = {...req.headers,  ...{'Authorization': 'Bearer ' + idToken}};
    }

    return fetch(url, req)
  })
}

export default class API {
  static getWorkList() {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works`)
      .then(res => res.arrayBuffer())
      .then(data => {
        const pb = worklist_pb.WorkListPb.deserializeBinary(new Uint8Array(data));
        return this.worklistPbToObject(pb);
      })
  }

  static addWork(title) {
    const param = new command_request_pb.CreateWorkRequestPb();
    param.setTitle(title);

    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works`, {
      method: 'POST',
      headers: {'Content-Type': 'application/octet-stream'},
      body: param.serializeBinary()
    });
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
    const timestamp = new google_protobuf_timestamp_pb.Timestamp();
    timestamp.fromDate(time);

    const param = new command_request_pb.ChangeWorkStateRequestPb();
    param.setTime(timestamp)

    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works/${id}/${method}`, {
      method: 'POST',
      headers: {'Content-Type': 'application/octet-stream'},
      body: param.serializeBinary()
    });
  }

  static deleteWork(id) {
    return fetchRequest(`${process.env.REACT_APP_API_ORIGIN}/v1/works/${id}`, {
      method: 'DELETE'
    });
  }

  static worklistPbToObject(pb) {
    const pbObj = pb.toObject();

    const toDate = (t) => {
      if (!t) {
        return null
      }
      return new Date((t.seconds * 1000) + (t.nanos / 1000000))
    }


    return {
      works: (pbObj.worksList || []).map(work => {
        return {
          id: work.id,
          title: work.title,
          state: work.state,
          baseWorkingTime: toDate(work.baseWorkingTime),
          startedAt: toDate(work.startedAt),
          pausedAt: toDate(work.pausedAt),
          createdAt: toDate(work.createdAt),
          updatedAt: toDate(work.updatedAt),
        };
      }),
      nextPageToken: pbObj.nextPageToken
    };
  }
}
