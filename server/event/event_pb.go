package event

import (
	"fmt"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
)

// MarshalPb takes a Event and encodes it into the wire format, returning the data.
func MarshalPb(e Event) ([]byte, error) {
	pb, err := convertToEventPb(e)
	if err != nil {
		return nil, err
	}

	return proto.Marshal(&pb)
}

// UnmarshalPb parses the protocol buffer representation in buf and places the decoded result in dst.
// If the struct underlying dst does not match the data in buf, the results can be unpredictable.
func UnmarshalPb(buf []byte, dst *Event) error {
	var pb EventPb
	err := proto.Unmarshal(buf, &pb)

	if err != nil {
		return err
	}

	e, err := convertToEvent(pb)
	if err != nil {
		return err
	}

	*dst = e
	return nil
}

func convertToEventPb(e Event) (EventPb, error) {
	time, err := ptypes.TimestampProto(e.Time)
	if err != nil {
		return EventPb{}, err
	}

	createdAt, err := ptypes.TimestampProto(e.CreatedAt)
	if err != nil {
		return EventPb{}, err
	}

	return EventPb{
		Id:        e.ID,
		PrevId:    e.PrevID,
		UserId:    e.UserID,
		WorkId:    e.WorkID,
		Action:    convertToActionPb(e.Action),
		Title:     e.Title,
		Time:      time,
		CreatedAt: createdAt,
	}, nil
}

func convertToEvent(pb EventPb) (Event, error) {
	time, err := ptypes.Timestamp(pb.GetTime())
	if err != nil {
		return Event{}, err
	}

	createdAt, err := ptypes.Timestamp(pb.GetCreatedAt())
	if err != nil {
		return Event{}, err
	}

	return Event{
		ID:        pb.GetId(),
		PrevID:    pb.GetPrevId(),
		UserID:    pb.GetUserId(),
		WorkID:    pb.GetWorkId(),
		Action:    convertToAction(pb.GetAction()),
		Title:     pb.GetTitle(),
		Time:      time,
		CreatedAt: createdAt,
	}, nil
}

func convertToActionPb(a Action) EventPb_Action {
	switch a {
	case UnknownEvent:
		return EventPb_ACTION_UNSPECIFIED
	case CreateWork:
		return EventPb_CREATE_WORK
	case UpdateWork:
		return EventPb_UPDATE_WORK
	case DeleteWork:
		return EventPb_DELETE_WORK
	case StartWork:
		return EventPb_START_WORK
	case PauseWork:
		return EventPb_PAUSE_WORK
	case ResumeWork:
		return EventPb_RESUME_WORK
	case FinishWork:
		return EventPb_FINISH_WORK
	case CancelFinishWork:
		return EventPb_CANCEL_FINISH_WORK
	default:
		panic(fmt.Sprintf("unknown EventAction: %s", a))
	}
}

func convertToAction(pb EventPb_Action) Action {
	switch pb {
	case EventPb_ACTION_UNSPECIFIED:
		return UnknownEvent
	case EventPb_CREATE_WORK:
		return CreateWork
	case EventPb_UPDATE_WORK:
		return UpdateWork
	case EventPb_DELETE_WORK:
		return DeleteWork
	case EventPb_START_WORK:
		return StartWork
	case EventPb_PAUSE_WORK:
		return PauseWork
	case EventPb_RESUME_WORK:
		return ResumeWork
	case EventPb_FINISH_WORK:
		return FinishWork
	case EventPb_CANCEL_FINISH_WORK:
		return CancelFinishWork
	default:
		panic(fmt.Sprintf("unknown EventPb_Action: %s", pb))
	}
}
