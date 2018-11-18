package model

import (
	"fmt"
	"time"
)

// EventID is a type for event id.
type EventID string

// Event is a event for a Work.
type Event struct {
	ID        EventID
	PrevID    EventID
	WorkID    WorkID
	Type      EventType
	Title     string
	Time      time.Time
	CreatedAt time.Time
}

// EventType is a type for a event.
type EventType int8

// Event types.
const (
	UnknownEvent     EventType = 0
	CreateWork       EventType = 1
	UpdateWork       EventType = 2
	DeleteWork       EventType = 3
	StartWork        EventType = 4
	PauseWork        EventType = 5
	ResumeWork       EventType = 6
	FinishWork       EventType = 7
	CancelFinishWork EventType = 8
)

func (t EventType) String() string {
	switch t {
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
		panic(fmt.Sprintf("unknown EventType: %d", t))
	}
}
