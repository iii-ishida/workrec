package model

import (
	"fmt"
	"time"

	"github.com/iii-ishida/workrec/server/event"
)

// WorkList is a work list.
type WorkList struct {
	Works         []WorkListItem
	NextPageToken string
}

// WorkListItem is a item of WorkList.
type WorkListItem struct {
	ID              string
	Title           string
	BaseWorkingTime time.Time
	PausedAt        time.Time
	State           WorkState
	StartedAt       time.Time
	CreatedAt       time.Time
	UpdatedAt       time.Time
	IsDeleted       bool
}

// ApplyEventsToWork applies events to work and returns the work.
func ApplyEventsToWork(work WorkListItem, events []event.Event) WorkListItem {
	for _, e := range events {
		switch e.Action {
		case event.CreateWork:
			work = WorkListItem{
				ID:              string(e.WorkID),
				Title:           e.Title,
				State:           Unstarted,
				BaseWorkingTime: time.Time{},
				PausedAt:        time.Time{},
				StartedAt:       time.Time{},
				CreatedAt:       e.CreatedAt,
				UpdatedAt:       e.CreatedAt,
			}

		case event.UpdateWork:
			work.Title = e.Title
			work.UpdatedAt = e.CreatedAt

		case event.DeleteWork:
			work.IsDeleted = true

		case event.StartWork:
			work.State = Started
			work.BaseWorkingTime = e.Time
			work.StartedAt = e.Time
			work.UpdatedAt = e.CreatedAt

		case event.PauseWork:
			work.State = Paused
			work.PausedAt = e.Time
			work.UpdatedAt = e.CreatedAt

		case event.ResumeWork:
			work.State = Resumed
			work.BaseWorkingTime = work.calculateBaseWorkingTime(e.Time)
			work.PausedAt = time.Time{}
			work.UpdatedAt = e.CreatedAt

		case event.FinishWork:
			if work.State != Paused {
				work.PausedAt = e.Time
			}

			work.State = Finished
			work.UpdatedAt = e.CreatedAt

		case event.CancelFinishWork:
			work.State = Paused
			work.UpdatedAt = e.CreatedAt
		}
	}

	return work
}

func (w WorkListItem) calculateBaseWorkingTime(resumedAt time.Time) time.Time {
	pausedAt := w.PausedAt
	pausingTime := resumedAt.Sub(pausedAt)

	return w.BaseWorkingTime.Add(pausingTime)
}

// WorkState is a state for a work.
type WorkState int8

// States for a work.
const (
	UnknownState WorkState = 0
	Unstarted    WorkState = 1
	Started      WorkState = 2
	Paused       WorkState = 3
	Resumed      WorkState = 4
	Finished     WorkState = 5
)

func (s WorkState) String() string {
	switch s {
	case UnknownState:
		return "Unknown"
	case Unstarted:
		return "Unstarted"
	case Started:
		return "Started"
	case Paused:
		return "Paused"
	case Resumed:
		return "Resumed"
	case Finished:
		return "Finished"
	default:
		panic(fmt.Sprintf("unknown WorkState: %d", s))
	}
}
