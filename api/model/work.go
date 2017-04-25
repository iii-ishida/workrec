package model

import (
	"workrec/api/event"
	"workrec/libs/util"
)

// State is a work action state.
type State int

// State enum.
const (
	Unstarted State = 0
	Started   State = 1
	Paused    State = 2
	Resumed   State = 3
	Finished  State = 4
)

// Work model
type Work struct {
	ID        string
	Title     string
	Actions   []Action
	UpdatedAt int64
	change    event.Event
}

// Action model
type Action struct {
	ID    string
	State State
	Time  int64
}

// CreateWork returns a new Work.
func CreateWork(title string) Work {
	w := Work{
		ID:        newWorkID(),
		Title:     title,
		Actions:   []Action{},
		UpdatedAt: util.Now(),
	}
	w.change = event.NewForCreated(w.ID, title, w.UpdatedAt)
	return w
}

// Update returns a updated Work.
func (w Work) Update(title string) Work {
	w.Title = title
	w.UpdatedAt = util.Now()
	w.change = event.NewForUpdated(w.ID, title, w.UpdatedAt)
	return w
}

// Delete returns a deleted Work.
func (w Work) Delete() Work {
	w = Work{ID: w.ID}
	w.UpdatedAt = util.Now()
	w.change = event.NewForDeleted(w.ID, w.UpdatedAt)
	return w
}

// Start returns the started Work.
func (w Work) Start(time int64) Work {
	w = w.addAction(Started, time)
	w.UpdatedAt = util.Now()
	w.change = event.NewForStarted(w.ID, time, w.UpdatedAt)
	return w
}

// Pause returns the paused Work.
func (w Work) Pause(time int64) Work {
	w = w.addAction(Paused, time)
	w.UpdatedAt = util.Now()
	w.change = event.NewForPaused(w.ID, time, w.UpdatedAt)
	return w
}

// Resume returns the resumed Work.
func (w Work) Resume(time int64) Work {
	w = w.addAction(Resumed, time)
	w.UpdatedAt = util.Now()
	w.change = event.NewForResumed(w.ID, time, w.UpdatedAt)
	return w
}

// Finish returns the finished Work.
func (w Work) Finish(time int64) Work {
	w = w.addAction(Finished, time)
	w.UpdatedAt = util.Now()
	w.change = event.NewForFinished(w.ID, time, w.UpdatedAt)
	return w
}

// Equal reports whether w and u represent the same Work.
func (w Work) Equal(u Work) bool {
	eq := w.ID == u.ID &&
		w.Title == u.Title &&
		(w.Actions == nil) == (u.Actions == nil) &&
		len(w.Actions) == len(u.Actions) &&
		w.UpdatedAt == u.UpdatedAt

	if !eq {
		return false
	}

	for i, a := range w.Actions {
		if !a.Equal(u.Actions[i]) {
			return false
		}
	}
	return true
}

// Equal reports whether a and u represent the same Action.
func (a Action) Equal(u Action) bool {
	return a.ID == u.ID &&
		a.State == u.State &&
		a.Time == u.Time
}

// IsEmpty reports whether w is empey.
func (w Work) IsEmpty() bool {
	return w.ID == ""
}

// IsDeleted reports whether w is deleted.
func (w Work) IsDeleted() bool {
	return w.change.Type == event.Deleted
}

// Change returns the event of w.
func (w Work) Change() event.Event {
	return w.change
}

// DeepCopy returns deep copied w.
func (w Work) DeepCopy() Work {
	actions := make([]Action, len(w.Actions))
	copy(actions, w.Actions)
	w.Actions = actions
	return w
}

func (w Work) addAction(state State, time int64) Work {
	w.Actions = append(w.Actions, Action{
		ID:    newActionID(w.ID),
		State: state,
		Time:  time,
	})
	return w
}

func newWorkID() string {
	return util.NewUUID()
}

func newActionID(workID string) string {
	return workID + "_" + util.NewUUID()
}

func (s State) String() string {
	switch s {
	case Unstarted:
		return "Unstarted"
	case Started:
		return "Started"
	case Paused:
		return "Paused"
	case Resumed:
		return "Resumed"
	case Finished:
		return "Resumed"
	default:
		return "UNKNOWN"
	}
}
