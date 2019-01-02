package event_test

import (
	"testing"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
)

func TestMarshalEventPb(t *testing.T) {
	var (
		id             = util.NewUUID()
		prevID         = util.NewUUID()
		workID         = util.NewUUID()
		action         = event.CreateWork
		actionPb       = event.EventPb_CREATE_WORK
		title          = "a title"
		tm             = time.Now().Add(-1 * time.Hour)
		tmPb, _        = ptypes.TimestampProto(tm)
		createdAt      = time.Now()
		createdAtPb, _ = ptypes.TimestampProto(createdAt)

		e = event.Event{
			ID:        id,
			PrevID:    prevID,
			WorkID:    workID,
			Action:    action,
			Title:     title,
			Time:      tm,
			CreatedAt: createdAt,
		}
	)

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, err := event.MarshalPb(e)
		if err != nil {
			t.Fatalf("MarshalEventPb error = %#v", err)
		}

		var pb event.EventPb
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
		t.Run("Action", func(t *testing.T) {
			if pb.Action != actionPb {
				t.Errorf("pb.Action = %s, wants = %s", pb.Action, actionPb)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if pb.Title != title {
				t.Errorf("pb.Title = %s, wants = %s", pb.Title, title)
			}
		})
		t.Run("Time", func(t *testing.T) {
			if pb.Time.String() != tmPb.String() {
				t.Errorf("pb.Time = %s, wants = %s", pb.Time, tmPb)
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
	var (
		id             = util.NewUUID()
		prevID         = util.NewUUID()
		workID         = util.NewUUID()
		action         = event.CreateWork
		actionPb       = event.EventPb_CREATE_WORK
		title          = "a title"
		tm             = time.Now().Add(-1 * time.Hour)
		tmPb, _        = ptypes.TimestampProto(tm)
		createdAt      = time.Now()
		createdAtPb, _ = ptypes.TimestampProto(createdAt)

		pb = event.EventPb{
			Id:        id,
			PrevId:    prevID,
			WorkId:    workID,
			Action:    actionPb,
			Title:     title,
			Time:      tmPb,
			CreatedAt: createdAtPb,
		}
	)

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, _ := proto.Marshal(&pb)

		var e event.Event
		if err := event.UnmarshalPb(buf, &e); err != nil {
			t.Fatalf("MarshalPb error = %#v", err)
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
		t.Run("Action", func(t *testing.T) {
			if e.Action != action {
				t.Errorf("e.Action = %s, wants = %s", e.Action, action)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if e.Title != title {
				t.Errorf("e.Title = %s, wants = %s", e.Title, title)
			}
		})
		t.Run("Time", func(t *testing.T) {
			if !e.Time.Equal(tm) {
				t.Errorf("e.Time = %s, wants = %s", e.Time, tm)
			}
		})
		t.Run("CreatedAt", func(t *testing.T) {
			if !e.CreatedAt.Equal(createdAt) {
				t.Errorf("e.CreatedAt = %s, wants = %s", e.CreatedAt, createdAt)
			}
		})
	})

	t.Run("bufが不正な値の場合はエラーになること", func(t *testing.T) {
		var e event.Event
		buf := []byte("invalidvalue")

		if err := event.UnmarshalPb(buf, &e); err == nil {
			t.Error("err is nil, wants not nil")
		}
	})
}
