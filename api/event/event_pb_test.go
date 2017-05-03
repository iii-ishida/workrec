package event_test

import (
	"reflect"
	"testing"
	"time"
	"workrec/api/event"

	"github.com/golang/protobuf/proto"
)

func TestMarshal(t *testing.T) {
	e, pb := eventsForTest()

	b, err := event.MarshalPb(e)
	if err != nil {
		t.Fatalf("MarshalPb error = %v", err)
	}

	wants, _ := proto.Marshal(&pb)
	if !reflect.DeepEqual(b, wants) {
		t.Errorf("MarshalPb() = %#v, wants = %#v", b, wants)
	}
}

func TestUnmarshal(t *testing.T) {
	wants, pb := eventsForTest()

	b, _ := proto.Marshal(&pb)
	e, err := event.UnmarshalPb(b)
	if err != nil {
		t.Fatalf("UnmarshalPb error = %v", err)
	}

	if !reflect.DeepEqual(e, wants) {
		t.Errorf("UnmarshalPb() = %#v, wants = %#v", e, wants)
	}
}

func eventsForTest() (event.Event, event.EventPb) {
	id := "w-123-456"
	workID := "123"
	title := "A"
	tm := time.Date(2017, 1, 12, 3, 45, 6, 7, time.UTC).UnixNano()
	updatedAt := time.Date(2017, 2, 3, 4, 56, 7, 8, time.UTC).UnixNano()

	e := event.Event{
		Type:      event.Created,
		ID:        id,
		WorkID:    workID,
		Title:     title,
		Time:      tm,
		UpdatedAt: updatedAt,
	}
	pb := event.EventPb{
		Type:      event.EventPb_Created,
		Id:        id,
		WorkId:    workID,
		Title:     title,
		Time:      tm,
		UpdatedAt: updatedAt,
	}

	return e, pb
}
