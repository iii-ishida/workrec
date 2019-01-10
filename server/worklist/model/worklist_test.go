package model_test

import (
	"testing"

	"time"

	"github.com/iii-ishida/workrec/server/event"
	"github.com/iii-ishida/workrec/server/util"
	"github.com/iii-ishida/workrec/server/worklist/model"
)

func TestApplyEventsToWork(t *testing.T) {
	var (
		now    = time.Now()
		workID = "workid-1"
	)

	t.Run("CreateWork", func(t *testing.T) {
		title := "some title"
		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: title, CreatedAt: now},
		})

		if work.ID != workID {
			t.Errorf("ID = %s, wants = %s", work.ID, workID)
		}
		if work.Title != title {
			t.Errorf("Title = %s, wants = %s", work.Title, title)
		}
		if !work.BaseWorkingTime.IsZero() {
			t.Errorf("BaseWorkingTime = %s, wants = zero", work.BaseWorkingTime)
		}
		if !work.PausedAt.IsZero() {
			t.Errorf("PausedAt = %s, wants = zero", work.PausedAt)
		}
		if work.State != model.Unstarted {
			t.Errorf("State = %s, wants = %s", work.State, model.Unstarted)
		}
		if !work.StartedAt.IsZero() {
			t.Errorf("StartedAt = %s, wants = zero", work.StartedAt)
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

		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
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
		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.DeleteWork, CreatedAt: now.Add(1 * time.Second)},
		})

		if !work.IsDeleted {
			t.Errorf("IsDeleted = %t, wants = false", work.IsDeleted)
		}
	})

	t.Run("StartWork", func(t *testing.T) {
		startTime := now.Add(1 * time.Minute)
		updatedAt := now.Add(1 * time.Second)

		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: updatedAt},
		})

		if work.State != model.Started {
			t.Errorf("State = %s, wants = %s", work.State, model.Started)
		}
		if !work.BaseWorkingTime.Equal(startTime) {
			t.Errorf("BaseWorkingTime = %s, wants = %s", work.BaseWorkingTime, startTime)
		}
		if !work.PausedAt.IsZero() {
			t.Errorf("PausedAt = %s, wants = zero", work.PausedAt)
		}
		if !work.StartedAt.Equal(startTime) {
			t.Errorf("StartedAt = %s, wants = %s", work.StartedAt, startTime)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("PauseWork", func(t *testing.T) {
		startTime := now.Add(1 * time.Minute)
		pauseTime := now.Add(2 * time.Minute)

		updatedAt := now.Add(2 * time.Second)

		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: pauseTime, CreatedAt: updatedAt},
		})

		if work.State != model.Paused {
			t.Errorf("State = %s, wants = %s", work.State, model.Paused)
		}
		if !work.BaseWorkingTime.Equal(startTime) {
			t.Errorf("BaseWorkingTime = %s, wants = %s", work.BaseWorkingTime, pauseTime)
		}
		if !work.PausedAt.Equal(pauseTime) {
			t.Errorf("PausedAt = %s, wants = %s", work.PausedAt, pauseTime)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("ResumeWork", func(t *testing.T) {
		startTime := now.Add(1 * time.Minute)
		pauseTime := now.Add(2 * time.Minute)
		resumeTime := now.Add(3 * time.Minute)
		expectedBaseWorkingTime := startTime.Add(1 * time.Minute)

		updatedAt := now.Add(3 * time.Second)

		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: pauseTime, CreatedAt: now.Add(2 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.ResumeWork, Time: resumeTime, CreatedAt: updatedAt},
		})

		if work.State != model.Resumed {
			t.Errorf("State = %s, wants = %s", work.State, model.Resumed)
		}
		if !work.BaseWorkingTime.Equal(expectedBaseWorkingTime) {
			t.Errorf("BaseWorkingTime = %s, wants = %s", work.BaseWorkingTime, expectedBaseWorkingTime)
		}
		if !work.PausedAt.IsZero() {
			t.Errorf("PausedAt = %s, wants = zero", work.PausedAt)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})

	t.Run("FinishWork", func(t *testing.T) {
		startTime := now.Add(1 * time.Minute)
		pauseTime := now.Add(2 * time.Minute)
		resumeTime := now.Add(3 * time.Minute)
		finishTime := now.Add(4 * time.Minute)
		expectedBaseWorkingTime := startTime.Add(1 * time.Minute)

		updatedAt := now.Add(4 * time.Second)

		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: pauseTime, CreatedAt: now.Add(2 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.ResumeWork, Time: resumeTime, CreatedAt: now.Add(3 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.FinishWork, Time: finishTime, CreatedAt: updatedAt},
		})

		if work.State != model.Finished {
			t.Errorf("State = %s, wants = %s", work.State, model.Finished)
		}
		if !work.BaseWorkingTime.Equal(expectedBaseWorkingTime) {
			t.Errorf("BaseWorkingTime = %s, wants = %s", work.BaseWorkingTime, expectedBaseWorkingTime)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}

		t.Run("StartからFinishの場合はPausedAtを設定すること", func(t *testing.T) {
			work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
				{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
				{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), WorkID: workID, Action: event.FinishWork, Time: finishTime, CreatedAt: updatedAt},
			})

			if !work.PausedAt.Equal(finishTime) {
				t.Errorf("PausedAt = %s, wants = %s", work.PausedAt, finishTime)
			}
		})

		t.Run("PauseからFinishの場合はPausedAtを更新しないこと", func(t *testing.T) {
			work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
				{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
				{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: pauseTime, CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), WorkID: workID, Action: event.FinishWork, Time: finishTime, CreatedAt: updatedAt},
			})

			if !work.PausedAt.Equal(pauseTime) {
				t.Errorf("PausedAt = %s, wants = %s", work.PausedAt, pauseTime)
			}
		})

		t.Run("ResumeからFinishの場合はPausedAtを設定すること", func(t *testing.T) {
			work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
				{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
				{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
				{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: pauseTime, CreatedAt: now.Add(2 * time.Second)},
				{ID: util.NewUUID(), WorkID: workID, Action: event.ResumeWork, Time: resumeTime, CreatedAt: now.Add(3 * time.Second)},
				{ID: util.NewUUID(), WorkID: workID, Action: event.FinishWork, Time: finishTime, CreatedAt: updatedAt},
			})

			if !work.PausedAt.Equal(finishTime) {
				t.Errorf("PausedAt = %s, wants = %s", work.PausedAt, finishTime)
			}
		})
	})

	t.Run("CancelFinishWork", func(t *testing.T) {
		startTime := now.Add(1 * time.Minute)
		pauseTime := now.Add(2 * time.Minute)
		resumeTime := now.Add(3 * time.Minute)
		finishTime := now.Add(4 * time.Minute)
		cancelFinishTime := now.Add(5 * time.Minute)
		expectedBaseWorkingTime := startTime.Add(1 * time.Minute)

		updatedAt := now.Add(5 * time.Second)

		work := model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: workID, Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: workID, Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.PauseWork, Time: pauseTime, CreatedAt: now.Add(2 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.ResumeWork, Time: resumeTime, CreatedAt: now.Add(3 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.FinishWork, Time: finishTime, CreatedAt: now.Add(4 * time.Second)},
			{ID: util.NewUUID(), WorkID: workID, Action: event.CancelFinishWork, Time: cancelFinishTime, CreatedAt: updatedAt},
		})

		if work.State != model.Paused {
			t.Errorf("State = %s, wants = %s", work.State, model.Paused)
		}
		if !work.BaseWorkingTime.Equal(expectedBaseWorkingTime) {
			t.Errorf("BaseWorkingTime = %s, wants = %s", work.BaseWorkingTime, expectedBaseWorkingTime)
		}
		if !work.PausedAt.Equal(finishTime) {
			t.Errorf("PausedAt = %s, wants = %s", work.PausedAt, finishTime)
		}
		if !work.UpdatedAt.Equal(updatedAt) {
			t.Errorf("UpdatedAt = %s, wants = %s", work.UpdatedAt, updatedAt)
		}
	})
}

func TestCalculateBaseWorkingTime(t *testing.T) {
	var (
		now           = time.Now()
		startTime, _  = time.Parse(time.RFC3339, "2019-01-08T09:30:00Z")
		pauseTime, _  = time.Parse(time.RFC3339, "2019-01-08T12:00:00Z")
		resumeTime, _ = time.Parse(time.RFC3339, "2019-01-08T13:00:00Z")

		observedAt, _ = time.Parse(time.RFC3339, "2019-01-08T18:00:00Z")

		expectedWorkingTimeInMinute = 7.5 * 60.0

		work = model.ApplyEventsToWork(model.WorkListItem{}, []event.Event{
			{ID: util.NewUUID(), WorkID: "workID", Action: event.CreateWork, Title: "some title", CreatedAt: now},
			{ID: util.NewUUID(), WorkID: "workID", Action: event.StartWork, Time: startTime, CreatedAt: now.Add(1 * time.Second)},
			{ID: util.NewUUID(), WorkID: "workID", Action: event.PauseWork, Time: pauseTime, CreatedAt: now.Add(2 * time.Second)},
			{ID: util.NewUUID(), WorkID: "workID", Action: event.ResumeWork, Time: resumeTime, CreatedAt: now.Add(3 * time.Second)},
		})

		workingTimeInMinute = observedAt.Sub(work.BaseWorkingTime).Minutes()
	)

	if workingTimeInMinute != expectedWorkingTimeInMinute {
		t.Errorf("workingTimeInMinute = %f, wants = %f", workingTimeInMinute, expectedWorkingTimeInMinute)
	}
}
