package event

import "workrec/libs/util"

type typ int

// Event Types
const (
	Unknown  typ = 0
	Created  typ = 1
	Updated  typ = 2
	Deleted  typ = 3
	Started  typ = 4
	Paused   typ = 5
	Resumed  typ = 6
	Finished typ = 7
)

// Event model
type Event struct {
	Type      typ
	ID        string
	WorkID    string
	Title     string
	Time      int64
	UpdatedAt int64
}

// NewForCreated returns a WorkCreated Event.
func NewForCreated(workID, title string, updatedAt int64) Event {
	return Event{
		Type:      Created,
		ID:        newEventID(workID),
		WorkID:    workID,
		Title:     title,
		UpdatedAt: updatedAt,
	}
}

// NewForUpdated returns a WorkUpdated Event.
func NewForUpdated(workID, title string, updatedAt int64) Event {
	return Event{
		Type:      Updated,
		ID:        newEventID(workID),
		WorkID:    workID,
		Title:     title,
		UpdatedAt: updatedAt,
	}
}

// NewForDeleted returns a WorkDeleted Event.
func NewForDeleted(workID string, updatedAt int64) Event {
	return Event{
		Type:      Deleted,
		ID:        newEventID(workID),
		WorkID:    workID,
		UpdatedAt: updatedAt,
	}
}

// NewForStarted returns a WorkStarted Event.
func NewForStarted(workID string, time, updatedAt int64) Event {
	return Event{
		Type:      Started,
		ID:        newEventID(workID),
		WorkID:    workID,
		Time:      time,
		UpdatedAt: updatedAt,
	}
}

// NewForPaused returns a WorkPaused Event.
func NewForPaused(workID string, time, updatedAt int64) Event {
	return Event{
		Type:      Paused,
		ID:        newEventID(workID),
		WorkID:    workID,
		Time:      time,
		UpdatedAt: updatedAt,
	}
}

// NewForResumed returns a WorkResumed Event.
func NewForResumed(workID string, time, updatedAt int64) Event {
	return Event{
		Type:      Resumed,
		ID:        newEventID(workID),
		WorkID:    workID,
		Time:      time,
		UpdatedAt: updatedAt,
	}
}

// NewForFinished returns a WorkFinished Event.
func NewForFinished(workID string, time, updatedAt int64) Event {
	return Event{
		Type:      Finished,
		ID:        newEventID(workID),
		WorkID:    workID,
		Time:      time,
		UpdatedAt: updatedAt,
	}
}

func newEventID(workID string) string {
	return "w-" + workID + "-" + util.NewUUID()
}
