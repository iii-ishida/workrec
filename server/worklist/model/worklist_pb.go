package model

import (
	"fmt"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
)

// MarshalWorkListPb takes a WorkList and encodes it into the wire format, returning the data.
func MarshalWorkListPb(list WorkList) ([]byte, error) {
	worksPb := make([]*WorkListItemPb, len(list.Works))
	for i, w := range list.Works {
		pb, err := convertToWorkListItemPb(w)
		if err != nil {
			return nil, err
		}
		worksPb[i] = &pb
	}

	pb := WorkListPb{
		Works:         worksPb,
		NextPageToken: list.NextPageToken,
	}

	return proto.Marshal(&pb)
}

// MarshalWorkListItemPb takes a Work and encodes it into the wire format, returning the data.
func MarshalWorkListItemPb(w WorkListItem) ([]byte, error) {
	pb, err := convertToWorkListItemPb(w)
	if err != nil {
		return nil, err
	}

	return proto.Marshal(&pb)
}

// UnmarshalWorkListItemPb parses the protocol buffer representation in buf and places the decoded result in dst.
// If the struct underlying dst does not match the data in buf, the results can be unpredictable.
func UnmarshalWorkListItemPb(buf []byte, dst *WorkListItem) error {
	var pb WorkListItemPb
	err := proto.Unmarshal(buf, &pb)

	if err != nil {
		return err
	}

	w, err := convertToWorkListItem(pb)
	if err != nil {
		return err
	}

	*dst = w
	return nil
}

func convertToWorkListItemPb(w WorkListItem) (WorkListItemPb, error) {
	createdAt, err := ptypes.TimestampProto(w.CreatedAt)
	if err != nil {
		return WorkListItemPb{}, err
	}

	updatedAt, err := ptypes.TimestampProto(w.UpdatedAt)
	if err != nil {
		return WorkListItemPb{}, err
	}

	return WorkListItemPb{
		Id:        string(w.ID),
		Title:     w.Title,
		State:     convertToWorkStatePb(w.State),
		CreatedAt: createdAt,
		UpdatedAt: updatedAt,
	}, nil
}

func convertToWorkListItem(pb WorkListItemPb) (WorkListItem, error) {
	createdAt, err := ptypes.Timestamp(pb.CreatedAt)
	if err != nil {
		return WorkListItem{}, err
	}
	updatedAt, err := ptypes.Timestamp(pb.UpdatedAt)
	if err != nil {
		return WorkListItem{}, err
	}

	return WorkListItem{
		ID:        pb.Id,
		Title:     pb.Title,
		State:     convertToWorkState(pb.State),
		CreatedAt: createdAt,
		UpdatedAt: updatedAt,
	}, nil
}

func convertToWorkStatePb(s WorkState) WorkListItemPb_State {
	switch s {
	case UnknownState:
		return WorkListItemPb_STATE_UNSPECIFIED
	case Unstarted:
		return WorkListItemPb_UNSTARTED
	case Started:
		return WorkListItemPb_STARTED
	case Paused:
		return WorkListItemPb_PAUSED
	case Resumed:
		return WorkListItemPb_RESUMED
	case Finished:
		return WorkListItemPb_FINISHED
	default:
		panic(fmt.Sprintf("unknown WorkState: %s", s))
	}
}

func convertToWorkState(pb WorkListItemPb_State) WorkState {
	switch pb {
	case WorkListItemPb_STATE_UNSPECIFIED:
		return UnknownState
	case WorkListItemPb_UNSTARTED:
		return Unstarted
	case WorkListItemPb_STARTED:
		return Started
	case WorkListItemPb_PAUSED:
		return Paused
	case WorkListItemPb_RESUMED:
		return Resumed
	case WorkListItemPb_FINISHED:
		return Finished
	default:
		panic(fmt.Sprintf("unknown WorkListItemPb_State : %s", pb))
	}
}
