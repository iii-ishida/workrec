package model_test

import (
	"testing"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/util"
)

func TestMarshalEventPb(t *testing.T) {
	id := util.NewUUID()
	prevID := util.NewUUID()
	workID := util.NewUUID()
	eventType := model.CreateWork
	eventTypePb := model.EventPb_CREATE_WORK
	title := "a title"
	eventTime := time.Now().Add(-1 * time.Hour)
	eventTimePb, _ := ptypes.TimestampProto(eventTime)
	createdAt := time.Now()
	createdAtPb, _ := ptypes.TimestampProto(createdAt)

	e := model.Event{
		ID:        id,
		PrevID:    prevID,
		WorkID:    workID,
		Type:      eventType,
		Title:     title,
		Time:      eventTime,
		CreatedAt: createdAt,
	}

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, err := model.MarshalEventPb(e)
		if err != nil {
			t.Fatalf("MarshalEventPb error = %#v", err)
		}

		var pb model.EventPb
		proto.Unmarshal(buf, &pb)

		t.Run("Id", func(t *testing.T) {
			if pb.Id != id {
				t.Errorf("pb.Id = %s, wants = %s", pb.Id, id)
			}
		})
		t.Run("PrevId", func(t *testing.T) {
			if pb.PrevId != prevID {
				t.Errorf("pb.PrevId = %s, wants = %s", pb.PrevId, prevID)
			}
		})
		t.Run("WorkId", func(t *testing.T) {
			if pb.WorkId != workID {
				t.Errorf("pb.WorkId = %s, wants = %s", pb.WorkId, workID)
			}
		})
		t.Run("Type", func(t *testing.T) {
			if pb.Type != eventTypePb {
				t.Errorf("pb.Type = %s, wants = %s", pb.Type, eventTypePb)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if pb.Title != title {
				t.Errorf("pb.Title = %s, wants = %s", pb.Title, title)
			}
		})
		t.Run("Time", func(t *testing.T) {
			if pb.Time.String() != eventTimePb.String() {
				t.Errorf("pb.Time = %s, wants = %s", pb.Time, eventTimePb)
			}
		})
		t.Run("CreatedAt", func(t *testing.T) {
			if pb.CreatedAt.String() != createdAtPb.String() {
				t.Errorf("pb.CreatedAt = %s, wants = %s", pb.CreatedAt, createdAtPb)
			}
		})
	})
}

func TestUnmarshalEventPb(t *testing.T) {
	id := util.NewUUID()
	prevID := util.NewUUID()
	workID := util.NewUUID()
	eventType := model.CreateWork
	eventTypePb := model.EventPb_CREATE_WORK
	title := "a title"
	eventTime := time.Now().Add(-1 * time.Hour)
	eventTimePb, _ := ptypes.TimestampProto(eventTime)
	createdAt := time.Now()
	createdAtPb, _ := ptypes.TimestampProto(createdAt)

	pb := model.EventPb{
		Id:        id,
		PrevId:    prevID,
		WorkId:    workID,
		Type:      eventTypePb,
		Title:     title,
		Time:      eventTimePb,
		CreatedAt: createdAtPb,
	}

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, _ := proto.Marshal(&pb)

		var e model.Event
		if err := model.UnmarshalEventPb(buf, &e); err != nil {
			t.Fatalf("MarshalEventPb error = %#v", err)
		}

		t.Run("ID", func(t *testing.T) {
			if e.ID != id {
				t.Errorf("e.ID = %s, wants = %s", e.ID, id)
			}
		})
		t.Run("PrevID", func(t *testing.T) {
			if e.PrevID != prevID {
				t.Errorf("e.PrevID = %s, wants = %s", e.PrevID, prevID)
			}
		})
		t.Run("WorkID", func(t *testing.T) {
			if e.WorkID != workID {
				t.Errorf("e.WorkID = %s, wants = %s", e.WorkID, workID)
			}
		})
		t.Run("Type", func(t *testing.T) {
			if e.Type != eventType {
				t.Errorf("e.Type = %s, wants = %s", e.Type, eventType)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if e.Title != title {
				t.Errorf("e.Title = %s, wants = %s", e.Title, title)
			}
		})
		t.Run("Time", func(t *testing.T) {
			if !e.Time.Equal(eventTime) {
				t.Errorf("e.Time = %s, wants = %s", e.Time, eventTime)
			}
		})
		t.Run("CreatedAt", func(t *testing.T) {
			if !e.CreatedAt.Equal(createdAt) {
				t.Errorf("e.CreatedAt = %s, wants = %s", e.CreatedAt, createdAt)
			}
		})
	})

	t.Run("bufが不正な値の場合はエラーになること", func(t *testing.T) {
		var e model.Event
		buf := []byte("invalidvalue")

		if err := model.UnmarshalEventPb(buf, &e); err == nil {
			t.Error("err is nil, wants not nil")
		}
	})
}
