package event

import "github.com/golang/protobuf/proto"

// MarshalPb returns the protocol buffer encoding of e.
func MarshalPb(e Event) ([]byte, error) {
	pb := e.toPb()
	return proto.Marshal(&pb)
}

// UnmarshalPb returns buf as a Event.
func UnmarshalPb(buf []byte) (Event, error) {
	var pb EventPb
	err := proto.Unmarshal(buf, &pb)

	if err != nil {
		return Event{}, err
	}

	return pb.toEvent(), nil
}

func (e Event) toPb() EventPb {
	return EventPb{
		Type:      e.Type.toPb(),
		Id:        e.ID,
		WorkId:    e.WorkID,
		Title:     e.Title,
		Time:      e.Time,
		UpdatedAt: e.UpdatedAt,
	}
}

func (t typ) toPb() EventPb_Type {
	return EventPb_Type(t)
}

func (e EventPb) toEvent() Event {
	return Event{
		Type:      e.Type.toEventType(),
		ID:        e.Id,
		WorkID:    e.WorkId,
		Title:     e.Title,
		Time:      e.Time,
		UpdatedAt: e.UpdatedAt,
	}
}

func (t EventPb_Type) toEventType() typ {
	return typ(t)
}
