package worklist

import (
	"testing"
	"time"

	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
	"github.com/iii-ishida/workrec/server/worklist/model"
)

func TestApplyToWork(t *testing.T) {
	var (
		query  = NewQuery(Dependency{})
		now    = time.Now()
		workID = "workid-1"
	)

	t.Run("CreateWork", func(t *testing.T) {
		title := "some title"
		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: title, CreatedAt: now},
		})

		if work.ID != workID {
			t.Errorf("ID = %s, wants = %s", work.ID, workID)
		}
		if work.Title != title {
			t.Errorf("Title = %s, wants = %s", work.Title, title)
		}
		if work.State != model.Unstarted {
			t.Errorf("State = %s, wants = %s", work.State, model.Unstarted)
		}
		if !work.CreatedAt.Equal(now) {
			t.Errorf("CreatedAt = %s, wants = %s", work.CreatedAt, now)
		}
		if !work.UpdatedAt.Equal(now) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, now)
		}
		if work.IsDeleted {
			t.Errorf("IsDeleted = %t, wants = false", work.IsDeleted)
		}
	})

	t.Run("UpdateWork", func(t *testing.T) {
		updatedTitle := "updated title"
		updatedAt := now.Add(1 * time.Second)

		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.UpdateWork, Title: updatedTitle, CreatedAt: updatedAt},
		})

		if work.Title != updatedTitle {
			t.Errorf("Title = %s, wants = %s", work.Title, updatedTitle)
		}
		if work.State != model.Unstarted {
			t.Errorf("State = %s, wants = %s", work.State, model.Unstarted)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("DeleteWork", func(t *testing.T) {
		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.DeleteWork, CreatedAt: now.Add(1 * time.Second)},
		})

		if !work.IsDeleted {
			t.Errorf("IsDeleted = %t, wants = false", work.IsDeleted)
		}
	})

	t.Run("StartWork", func(t *testing.T) {
		updatedAt := now.Add(1 * time.Second)

		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: now.Add(1 * time.Minute), CreatedAt: updatedAt},
		})

		if work.State != model.Started {
			t.Errorf("State = %s, wants = %s", work.State, model.Started)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("PauseWork", func(t *testing.T) {
		updatedAt := now.Add(2 * time.Second)

		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: now.Add(1 * time.Minute), CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: now.Add(2 * time.Minute), CreatedAt: updatedAt},
		})

		if work.State != model.Paused {
			t.Errorf("State = %s, wants = %s", work.State, model.Paused)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("ResumeWork", func(t *testing.T) {
		updatedAt := now.Add(3 * time.Second)

		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: now.Add(1 * time.Minute), CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: now.Add(2 * time.Minute), CreatedAt: now.Add(2 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.ResumeWork, Time: now.Add(3 * time.Minute), CreatedAt: updatedAt},
		})

		if work.State != model.Resumed {
			t.Errorf("State = %s, wants = %s", work.State, model.Resumed)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("FinishWork", func(t *testing.T) {
		updatedAt := now.Add(4 * time.Second)

		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: now.Add(1 * time.Minute), CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: now.Add(2 * time.Minute), CreatedAt: now.Add(2 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.ResumeWork, Time: now.Add(3 * time.Minute), CreatedAt: now.Add(3 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.FinishWork, Time: now.Add(4 * time.Minute), CreatedAt: updatedAt},
		})

		if work.State != model.Finished {
			t.Errorf("State = %s, wants = %s", work.State, model.Finished)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("CancelFinishWork", func(t *testing.T) {
		updatedAt := now.Add(5 * time.Second)

		work, _ := query.applyToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: now.Add(1 * time.Minute), CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: now.Add(2 * time.Minute), CreatedAt: now.Add(2 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.ResumeWork, Time: now.Add(3 * time.Minute), CreatedAt: now.Add(3 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.FinishWork, Time: now.Add(4 * time.Minute), CreatedAt: now.Add(4 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.CancelFinishWork, Time: now.Add(5 * time.Minute), CreatedAt: updatedAt},
		})

		if work.State != model.Paused {
			t.Errorf("State = %s, wants = %s", work.State, model.Paused)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})
}
