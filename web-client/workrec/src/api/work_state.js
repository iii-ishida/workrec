const worklist_pb = require('./pb/worklist_pb');

export const {
  UNSTARTED,
  STARTED,
  PAUSED,
  RESUMED,
  FINISHED
} = worklist_pb.WorkListItemPb.State

