import axios from 'axios';
import { API_ORIGIN } from './env';
const worklist_pb = require('./pb/worklist_pb');
const command_request_pb = require('./pb/command_request_pb');

export default class API {
  static getWorkList() {
    return axios.get(`${API_ORIGIN}/v1/works`, {responseType: 'arraybuffer'}).then(ret => {
      const list = worklist_pb.WorkListPb.deserializeBinary(new Uint8Array(ret.data));
      return list.toObject();
    });
  }

  static addWork(title) {
    const param = new command_request_pb.CreateWorkRequestPb();
    param.setTitle(title);

    return axios.post(`${API_ORIGIN}/v1/works`, param.serializeBinary(), {headers: {'Content-Type': 'application/octet-stream'}});
  }

  static deleteWork(id) {
    return axios.delete(`${API_ORIGIN}/v1/works/${id}`);
  }
}
