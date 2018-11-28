package model

import (
	"fmt"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
)

// MarshalWorkPb takes a Work and encodes it into the wire format, returning the data.
func MarshalWorkPb(w Work) ([]byte, error) {
	pb, err := convertToWorkPb(w)
	if err != nil {
		return nil, err
	}

	return proto.Marshal(&pb)
}

// UnmarshalWorkPb parses the protocol buffer representation in buf and places the decoded result in dst.
// If the struct underlying dst does not match the data in buf, the results can be unpredictable.
func UnmarshalWorkPb(buf []byte, dst *Work) error {
	var pb WorkPb
	err := proto.Unmarshal(buf, &pb)

	if err != nil {
		return err
	}

	w, err := convertToWork(pb)
	if err != nil {
		return err
	}

	*dst = w
	return nil
}

func convertToWorkPb(w Work) (WorkPb, error) {
	time, err := ptypes.TimestampProto(w.Time)
	if err != nil {
		return WorkPb{}, err
	}

	updatedAt, err := ptypes.TimestampProto(w.UpdatedAt)
	if err != nil {
		return WorkPb{}, err
	}

	return WorkPb{
		Id:        w.ID,
		EventId:   w.EventID,
		Title:     w.Title,
		State:     convertToWorkStatePb(w.State),
		Time:      time,
		UpdatedAt: updatedAt,
	}, nil
}

func convertToWork(w WorkPb) (Work, error) {
	time, err := ptypes.Timestamp(w.Time)
	if err != nil {
		return Work{}, err
	}

	updatedAt, err := ptypes.Timestamp(w.UpdatedAt)
	if err != nil {
		return Work{}, err
	}

	return Work{
		ID:        w.Id,
		EventID:   w.EventId,
		Title:     w.Title,
		State:     convertToWorkState(w.State),
		Time:      time,
		UpdatedAt: updatedAt,
	}, nil
}

func convertToWorkStatePb(s WorkState) WorkPb_State {
	switch s {
	case UnknownState:
		return WorkPb_STATE_UNSPECIFIED
	case Unstarted:
		return WorkPb_UNSTARTED
	case Started:
		return WorkPb_STARTED
	case Paused:
		return WorkPb_PAUSED
	case Resumed:
		return WorkPb_RESUMED
	case Finished:
		return WorkPb_FINISHED
	default:
		panic(fmt.Sprintf("unknown WorkState: %s", s))
	}
}

func convertToWorkState(s WorkPb_State) WorkState {
	switch s {
	case WorkPb_STATE_UNSPECIFIED:
		return UnknownState
	case WorkPb_UNSTARTED:
		return Unstarted
	case WorkPb_STARTED:
		return Started
	case WorkPb_PAUSED:
		return Paused
	case WorkPb_RESUMED:
		return Resumed
	case WorkPb_FINISHED:
		return Finished
	default:
		panic(fmt.Sprintf("unknown WorkPb_State: %s", s))
	}
}
