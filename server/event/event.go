package event

import (
	"fmt"
	"time"
)

// Event is a event for a Work.
type Event struct {
	ID        string
	PrevID    string
	UserID    string
	WorkID    string
	Action    Action
	Title     string
	Time      time.Time
	CreatedAt time.Time
}

// Action is a action for event.
type Action int8

// Event actions.
const (
	UnknownEvent     Action = 0
	CreateWork       Action = 1
	UpdateWork       Action = 2
	DeleteWork       Action = 3
	StartWork        Action = 4
	PauseWork        Action = 5
	ResumeWork       Action = 6
	FinishWork       Action = 7
	CancelFinishWork Action = 8
)

func (a Action) String() string {
	switch a {
	case UnknownEvent:
		return "Unknown"
	case CreateWork:
		return "CreateWork"
	case UpdateWork:
		return "UpdateWork"
	case DeleteWork:
		return "DeleteWork"
	case StartWork:
		return "StartWork"
	case PauseWork:
		return "PauseWork"
	case ResumeWork:
		return "ResumeWork"
	case FinishWork:
		return "FinishWork"
	case CancelFinishWork:
		return "CancelFinishWork"
	default:
		panic(fmt.Sprintf("unknown EventAction: %d", a))
	}
}
