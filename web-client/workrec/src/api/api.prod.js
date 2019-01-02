import { API_ORIGIN } from '../env';
const worklist_pb = require('./pb/worklist_pb');
const command_request_pb = require('./pb/command_request_pb');

export default class API {
  static getWorkList() {
    return fetch(`${API_ORIGIN}/v1/works`)
      .then(res => res.arrayBuffer())
      .then(data => {
        const pb = worklist_pb.WorkListPb.deserializeBinary(new Uint8Array(data));
        return this.worklistPbToObject(pb);
      });
  }

  static addWork(title) {
    const param = new command_request_pb.CreateWorkRequestPb();
    param.setTitle(title);

    return fetch(`${API_ORIGIN}/v1/works`, {
      method: 'POST',
      headers: {'Content-Type': 'application/octet-stream'},
      body: param.serializeBinary()
    });
  }

  static deleteWork(id) {
    return fetch(`${API_ORIGIN}/v1/works/${id}`, {
      method: 'DELETE'
    });
  }

  static worklistPbToObject(pb) {
    const pbObj = pb.toObject();

    return {
      works: (pbObj.worksList || []).map(work => {
        return {
          id: work.id,
          title: work.title,
          state: work.state,
          createdAt: work.createdAt,
          updatedAt: work.updatedAt,
        };
      }),
      nextPageToken: pbObj.nextPageToken
    };
  }
}
