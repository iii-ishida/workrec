package model

import (
	"time"
	"workrec/api/event"
)

// State is a work state.
type State int

// State enum.
const (
	Unstarted State = 0
	Started   State = 1
	Paused    State = 2
	Resumed   State = 3
	Finished  State = 4
)

// List is work list.
type List struct {
	Works []Work `json:"works,omitempty"`
	Next  string `json:"next,omitempty"`
}

// Work is work for query.
type Work struct {
	ID             string `json:"id,omitempty"`
	Title          string `json:"title,omitempty"`
	State          State  `json:"state,omitempty"`
	WorkTime       int64  `json:"workTime,omitempty"`
	PauseTime      int64  `json:"pauseTime,omitempty"`
	StateChangedAt int64  `json:"stateChangedAt,omitempty"`
	UpdatedAt      int64  `json:"updatedAt,omitempty"`
}

// IsWorking reports whether w is working.
func (w Work) IsWorking() bool {
	return w.State == Started || w.State == Resumed
}

// Process returns processed w.
func (w Work) Process(e event.Event) Work {
	switch e.Type {
	case event.Created:
		return newWork(e)
	case event.Updated:
		w.Title = e.Title
		w.UpdatedAt = e.UpdatedAt
		return w
	case event.Started:
		w.State = Started
		w.StateChangedAt = e.Time
		w.UpdatedAt = e.UpdatedAt
		return w
	case event.Paused:
		w.State = Paused
		w.WorkTime = w.WorkTime + toMinutes(subTime(e.Time, w.StateChangedAt))
		w.StateChangedAt = e.Time
		w.UpdatedAt = e.UpdatedAt
		return w
	case event.Resumed:
		w.State = Resumed
		w.PauseTime = w.PauseTime + toMinutes(subTime(e.Time, w.StateChangedAt))
		w.StateChangedAt = e.Time
		w.UpdatedAt = e.UpdatedAt
		return w
	case event.Finished:
		// Working => Finish
		if w.IsWorking() {
			w.WorkTime = w.WorkTime + toMinutes(subTime(e.Time, w.StateChangedAt))
		}
		w.State = Finished
		w.StateChangedAt = e.Time
		w.UpdatedAt = e.UpdatedAt
		return w
	case event.Unknown:
	case event.Deleted:
	default:
		return w
	}
	return w
}

func subTime(t1, t2 int64) time.Duration {
	return time.Unix(t1, 0).Sub(time.Unix(t2, 0))
}

func toMinutes(d time.Duration) int64 {
	return int64(d / time.Minute)
}

func newWork(e event.Event) Work {
	return Work{
		ID:             e.WorkID,
		Title:          e.Title,
		State:          Unstarted,
		WorkTime:       0,
		PauseTime:      0,
		StateChangedAt: 0,
		UpdatedAt:      e.UpdatedAt,
	}
}
