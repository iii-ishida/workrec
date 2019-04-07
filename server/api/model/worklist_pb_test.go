package model_test

import (
	"testing"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/iii-ishida/workrec/server/api/model"
	"github.com/iii-ishida/workrec/server/util"
)

func TestMarshalWorkPb(t *testing.T) {
	var (
		id                   = util.NewUUID()
		workState            = model.Started
		workStatePb          = model.WorkListItemPb_STARTED
		title                = "a title"
		baseWorkingTime      = time.Now().Add(-1 * time.Hour)
		baseWorkingTimePb, _ = ptypes.TimestampProto(baseWorkingTime)
		pausedAt             = time.Now().Add(-2 * time.Hour)
		pausedAtPb, _        = ptypes.TimestampProto(pausedAt)
		startedAt            = time.Now().Add(-3 * time.Hour)
		startedAtPb, _       = ptypes.TimestampProto(startedAt)
		createdAt            = time.Now().Add(-4 * time.Hour)
		createdAtPb, _       = ptypes.TimestampProto(createdAt)
		updatedAt            = time.Now()
		updatedAtPb, _       = ptypes.TimestampProto(updatedAt)

		w = model.WorkListItem{
			ID:              id,
			Title:           title,
			BaseWorkingTime: baseWorkingTime,
			PausedAt:        pausedAt,
			State:           workState,
			StartedAt:       startedAt,
			CreatedAt:       createdAt,
			UpdatedAt:       updatedAt,
		}
	)

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, err := model.MarshalWorkListItemPb(w)
		if err != nil {
			t.Fatalf("MarshalWorkPb error = %#v", err)
		}

		var pb model.WorkListItemPb
		proto.Unmarshal(buf, &pb)

		t.Run("Id", func(t *testing.T) {
			if pb.Id != id {
				t.Errorf("pb.Id = %s, wants = %s", pb.Id, id)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if pb.Title != title {
				t.Errorf("pb.Title = %s, wants = %s", pb.Title, title)
			}
		})
		t.Run("BaseWorkingTime", func(t *testing.T) {
			if pb.BaseWorkingTime.String() != baseWorkingTimePb.String() {
				t.Errorf("pb.BaseWorkingTime = %s, wants = %s", pb.BaseWorkingTime, baseWorkingTimePb)
			}
		})
		t.Run("PausedAt", func(t *testing.T) {
			if pb.PausedAt.String() != pausedAtPb.String() {
				t.Errorf("pb.PausedAt = %s, wants = %s", pb.PausedAt, pausedAt)
			}
		})

		t.Run("State", func(t *testing.T) {
			if pb.State != workStatePb {
				t.Errorf("pb.State = %s, wants = %s", pb.State, workStatePb)
			}
		})
		t.Run("StartedAt", func(t *testing.T) {
			if pb.StartedAt.String() != startedAtPb.String() {
				t.Errorf("pb.StartedAt = %s, wants = %s", pb.StartedAt, startedAtPb)
			}
		})
		t.Run("CreatedAt", func(t *testing.T) {
			if pb.CreatedAt.String() != createdAtPb.String() {
				t.Errorf("pb.CreatedAt = %s, wants = %s", pb.CreatedAt, createdAtPb)
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
	var (
		id                   = util.NewUUID()
		workState            = model.Started
		workStatePb          = model.WorkListItemPb_STARTED
		title                = "a title"
		baseWorkingTime      = time.Now().Add(-1 * time.Hour)
		baseWorkingTimePb, _ = ptypes.TimestampProto(baseWorkingTime)
		pausedAt             = time.Now().Add(-2 * time.Hour)
		pausedAtPb, _        = ptypes.TimestampProto(pausedAt)
		startedAt            = time.Now().Add(-3 * time.Hour)
		startedAtPb, _       = ptypes.TimestampProto(startedAt)
		createdAt            = time.Now().Add(-4 * time.Hour)
		createdAtPb, _       = ptypes.TimestampProto(createdAt)
		updatedAt            = time.Now()
		updatedAtPb, _       = ptypes.TimestampProto(updatedAt)

		pb = model.WorkListItemPb{
			Id:              id,
			Title:           title,
			BaseWorkingTime: baseWorkingTimePb,
			PausedAt:        pausedAtPb,
			State:           workStatePb,
			StartedAt:       startedAtPb,
			CreatedAt:       createdAtPb,
			UpdatedAt:       updatedAtPb,
		}
	)

	t.Run("パラメータが変更されないこと", func(t *testing.T) {
		buf, _ := proto.Marshal(&pb)

		var w model.WorkListItem
		if err := model.UnmarshalWorkListItemPb(buf, &w); err != nil {
			t.Fatalf("MarshalWorkPb error = %#v", err)
		}

		t.Run("ID", func(t *testing.T) {
			if w.ID != id {
				t.Errorf("w.ID = %s, wants = %s", w.ID, id)
			}
		})
		t.Run("Title", func(t *testing.T) {
			if w.Title != title {
				t.Errorf("w.Title = %s, wants = %s", w.Title, title)
			}
		})
		t.Run("BaseWorkingTime", func(t *testing.T) {
			if !w.BaseWorkingTime.Equal(baseWorkingTime) {
				t.Errorf("w.BaseWorkingTime = %s, wants = %s", w.BaseWorkingTime, baseWorkingTime)
			}
		})
		t.Run("PausedAt", func(t *testing.T) {
			if !w.PausedAt.Equal(pausedAt) {
				t.Errorf("w.PausedAt = %s, wants = %s", w.PausedAt, pausedAt)
			}
		})
		t.Run("State", func(t *testing.T) {
			if w.State != workState {
				t.Errorf("w.State = %s, wants = %s", w.State, workState)
			}
		})
		t.Run("StartedAt", func(t *testing.T) {
			if !w.StartedAt.Equal(startedAt) {
				t.Errorf("w.StartedAt = %s, wants = %s", w.StartedAt, startedAt)
			}
		})
		t.Run("CreatedAt", func(t *testing.T) {
			if !w.CreatedAt.Equal(createdAt) {
				t.Errorf("w.CreatedAt = %s, wants = %s", w.CreatedAt, createdAt)
			}
		})
		t.Run("UpdatedAt", func(t *testing.T) {
			if !w.UpdatedAt.Equal(updatedAt) {
				t.Errorf("w.UpdatedAt = %s, wants = %s", w.UpdatedAt, updatedAt)
			}
		})
	})

	t.Run("bufが不正な値の場合はエラーになること", func(t *testing.T) {
		var w model.WorkListItem
		buf := []byte("invalidvalue")

		if err := model.UnmarshalWorkListItemPb(buf, &w); err == nil {
			t.Error("err is nil, wants not nil")
		}
	})
}
