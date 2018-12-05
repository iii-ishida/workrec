package model_test

import (
	"testing"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/command/model"
	"github.com/iii-ishida/workrec/server/util"
)

func TestMarshalWorkPb(t *testing.T) {
	id := util.NewUUID()
	eventID := util.NewUUID()
	workState := model.Started
	workStatePb := model.WorkPb_STARTED
	title := "a title"
	workTime := time.Now().Add(-2 * time.Hour)
	workTimePb, _ := ptypes.TimestampProto(workTime)
	updatedAt := time.Now()
	updatedAtPb, _ := ptypes.TimestampProto(updatedAt)

	w := model.Work{
		ID:        id,
		EventID:   eventID,
		Title:     title,
		Time:      workTime,
		State:     workState,
		UpdatedAt: updatedAt,
	}

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, err := model.MarshalWorkPb(w)
		if err != nil {
			t.Fatalf("MarshalWorkPb error = %#v", err)
		}

		var pb model.WorkPb
		proto.Unmarshal(buf, &pb)

		t.Run("Id", func(t *testing.T) {
			if pb.Id != id {
				t.Errorf("pb.Id = %s, wants = %s", pb.Id, id)
			}
		})
		t.Run("EventId", func(t *testing.T) {
			if pb.EventId != eventID {
				t.Errorf("pb.EventId = %s, wants = %s", pb.EventId, eventID)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if pb.Title != title {
				t.Errorf("pb.Title = %s, wants = %s", pb.Title, title)
			}
		})
		t.Run("Time", func(t *testing.T) {
			if pb.Time.String() != workTimePb.String() {
				t.Errorf("pb.Time = %s, wants = %s", pb.Time, workTimePb)
			}
		})
		t.Run("State", func(t *testing.T) {
			if pb.State != workStatePb {
				t.Errorf("pb.State = %s, wants = %s", pb.State, workStatePb)
			}
		})
		t.Run("UpdatedAt", func(t *testing.T) {
			if pb.UpdatedAt.String() != updatedAtPb.String() {
				t.Errorf("pb.UpdatedAt = %s, wants = %s", pb.UpdatedAt, updatedAtPb)
			}
		})
	})
}

func TestUnmarshalWorkPb(t *testing.T) {
	id := util.NewUUID()
	eventID := util.NewUUID()
	workState := model.Started
	workStatePb := model.WorkPb_STARTED
	title := "a title"
	workTime := time.Now().Add(-2 * time.Hour)
	workTimePb, _ := ptypes.TimestampProto(workTime)
	updatedAt := time.Now()
	updatedAtPb, _ := ptypes.TimestampProto(updatedAt)

	pb := model.WorkPb{
		Id:        id,
		EventId:   eventID,
		Title:     title,
		Time:      workTimePb,
		State:     workStatePb,
		UpdatedAt: updatedAtPb,
	}

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, _ := proto.Marshal(&pb)

		var w model.Work
		if err := model.UnmarshalWorkPb(buf, &w); err != nil {
			t.Fatalf("MarshalWorkPb error = %#v", err)
		}

		t.Run("ID", func(t *testing.T) {
			if w.ID != id {
				t.Errorf("w.ID = %s, wants = %s", w.ID, id)
			}
		})
		t.Run("EventID", func(t *testing.T) {
			if w.EventID != eventID {
				t.Errorf("w.EventID = %s, wants = %s", w.EventID, eventID)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if w.Title != title {
				t.Errorf("w.Title = %s, wants = %s", w.Title, title)
			}
		})
		t.Run("Time", func(t *testing.T) {
			if !w.Time.Equal(workTime) {
				t.Errorf("w.Time = %s, wants = %s", w.Time, workTime)
			}
		})
		t.Run("State", func(t *testing.T) {
			if w.State != workState {
				t.Errorf("w.State = %s, wants = %s", w.State, workState)
			}
		})
		t.Run("UpdatedAt", func(t *testing.T) {
			if !w.UpdatedAt.Equal(updatedAt) {
				t.Errorf("w.UpdatedAt = %s, wants = %s", w.UpdatedAt, updatedAt)
			}
		})
	})

	t.Run("bufが不正な値の場合はエラーになること", func(t *testing.T) {
		var w model.Work
		buf := []byte("invalidvalue")

		if err := model.UnmarshalWorkPb(buf, &w); err == nil {
			t.Error("err is nil, wants not nil")
		}
	})
}
